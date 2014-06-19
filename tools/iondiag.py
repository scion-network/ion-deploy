#!/usr/bin/env python

"""Tool to diagnose issues with an OOINet system instance"""

__author__ = 'Michael Meisinger'

import argparse
import datetime
import json
import pprint
import os
import shutil
import time
import threading
import yaml
import sys
import Queue


class IonDiagnose(object):

    def __init__(self):
        self.sysinfo = {}
        self.msgs = []

    def init_args(self):
        print "====================================================="
        print "OOINet iondiag -- Diagnostics and Operations Analysis"
        print "====================================================="
        parser = argparse.ArgumentParser(description="OOINet iondiag")
        parser.add_argument('-c', '--config', type=str, help='File path to config file', default="")
        parser.add_argument('-d', '--info_dir', type=str, help='System info directory')
        parser.add_argument('-l', '--load_info', action='store_true', help="Load from system info directory")
        parser.add_argument('-L', '--level', type=str, help='Minimum warning level', default="WARN")
        parser.add_argument('-n', '--no_save', action='store_true', help="Don't store system info")
        parser.add_argument('-i', '--interactive', action='store_true', help="Drop into interactive shell")
        parser.add_argument('-v', '--verbose', action='store_true', help="Verbose output")
        parser.add_argument('-o', '--only_do', type=str, help='Restict diag to D, R, C', default="rdc")
        self.opts, self.extra = parser.parse_known_args()

    def read_config(self, filename=None):
        if self.opts.config:
            filename = self.opts.config
        else:
            filename = "iondiag.cfg"
        print "Loading config from %s" % filename
        self.cfg = None
        if filename and os.path.exists(filename):
            with open(filename, "r") as f:
                cfg_str = f.read()
            self.cfg = yaml.load(cfg_str)
        if not self.cfg:
            self._errout("No config")
        self.sysname = self.cfg["system"]["name"]

    # -------------------------------------------------------------------------

    def get_system_info(self):
        print "Retrieving system information from operational servers"
        # Read rabbit
        if "R" in self.opts.only_do.upper():
            self._get_rabbit_info()

        # Read resources from postgres
        if "D" in self.opts.only_do.upper():
            self._get_db_info()

        # Read info from CEIctrl
        if "C" in self.opts.only_do.upper():
            self._get_cei_info()

    def _get_rabbit_info(self):
        import requests
        from requests.auth import HTTPBasicAuth
        mgmt = self.cfg["container"]["exchange"]["management"]
        url_prefix = "http://%s:%s" % (mgmt["host"], mgmt["port"])
        print " Getting RabbitMQ info from %s" % url_prefix
        rabbit_info = self.sysinfo.setdefault("rabbit", {})
        url1 = url_prefix + "/api/overview"
        resp = requests.get(url1, auth=HTTPBasicAuth(mgmt["username"], mgmt["password"]))
        rabbit_info["overview"] = resp.json()
        print "  ...retrieved %s overview entries" % (len(rabbit_info["overview"]))

        url2 = url_prefix + "/api/queues"
        resp = requests.get(url2, auth=HTTPBasicAuth(mgmt["username"], mgmt["password"]))
        rabbit_info["queues"] = resp.json()
        print "  ...retrieved %s queues" % (len(rabbit_info["queues"]))

        url3 = url_prefix + "/api/connections"
        resp = requests.get(url3, auth=HTTPBasicAuth(mgmt["username"], mgmt["password"]))
        rabbit_info["connections"] = resp.json()
        print "  ...retrieved %s connections" % (len(rabbit_info["connections"]))

        url4 = url_prefix + "/api/exchanges"
        resp = requests.get(url4, auth=HTTPBasicAuth(mgmt["username"], mgmt["password"]))
        rabbit_info["exchanges"] = resp.json()
        print "  ...retrieved %s exchanges" % (len(rabbit_info["exchanges"]))

        url5 = url_prefix + "/api/bindings"
        resp = requests.get(url5, auth=HTTPBasicAuth(mgmt["username"], mgmt["password"]))
        rabbit_info["bindings"] = resp.json()
        print "  ...retrieved %s bindings" % (len(rabbit_info["bindings"]))

    def _get_db_info(self):
        from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
        conn, dsn = self._get_db_connection()
        db_info = self.sysinfo.setdefault("db", {})
        try:
            print " Getting DB info from PostgreSQL as:", dsn.rsplit("=", 1)[0] + "=***"
            conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
            with conn.cursor() as cur:
                cur.execute("SELECT id,doc FROM ion_resources")
                rows = cur.fetchall()
                resources = {}
                for row in rows:
                    res_id, res_doc = row[0], row[1]
                    resources[res_id] = res_doc
                print "  ...retrieved %s resources" % (len(resources))
                db_info["resources"] = resources

                cur.execute("SELECT id,doc FROM ion_resources_dir")
                rows = cur.fetchall()
                dir_entries = {}
                for row in rows:
                    dir_id, dir_doc = row[0], row[1]
                    dir_entries[dir_id] = dir_doc
                print "  ...retrieved %s directory entries" % (len(dir_entries))
                db_info["directory"] = dir_entries
        finally:
            conn.close()

    def _get_db_connection(self):
        import psycopg2

        pgcfg = self.cfg["server"]["postgresql"]
        db_name = "%s_%s" % (self.sysname.lower(), pgcfg["database"])

        dsn = "host=%s port=%s dbname=%s user=%s password=%s" % (pgcfg["host"], pgcfg["port"], db_name, pgcfg["username"], pgcfg["password"])
        return psycopg2.connect(dsn), dsn

    def _get_cei_info(self):
        cei_info = self.sysinfo.setdefault("cei", {})

        print " Getting CEI info from:", self.cfg["server"]["zookeeper"]["hosts"]
        zk = self._get_zoo_connection()
        start_node = "/" + self.sysname
        if not zk.exists(start_node):
            self._errout("Cannot find start node %s" % start_node)
        zk.stop()

        self.queue = Queue.Queue()
        self.queue.put(start_node)
        num_threads = 20
        res_info, threads = [], []
        for i in range(num_threads):
            th_info = {}
            res_info.append(th_info)
            t = threading.Thread(target=self._zoo_get_thread, args=(th_info, i))
            t.daemon = True
            t.start()
            threads.append(t)

        for t in threads:
            t.join()

        zoo_info = {}
        for th_info in res_info:
            zoo_info.update(th_info)
        cei_info["zoo"] = zoo_info
        print "  ...retrieved %s CEI nodes" % (len(zoo_info))

    def _get_zoo_connection(self):
        from kazoo.client import KazooClient
        zkcfg = self.cfg["server"]["zookeeper"]
        zk = KazooClient(hosts=zkcfg["hosts"])
        zk.start()
        return zk

    def _zoo_get_thread(self, th_info, num):
        zk = self._get_zoo_connection()
        try:
            node = self.queue.get(True, 2)
            while node:
                data, stats = zk.get(node)
                try:
                    th_info[node] = json.loads(data) if data else {}
                except Exception:
                    th_info[node] = dict(error=True, value=data)
                ch_nodes = zk.get_children(node)
                for ch in ch_nodes:
                    ch_node = node + "/" + ch
                    self.queue.put(ch_node)
                node = self.queue.get(True, 0.5)
        except Queue.Empty:
            pass

        zk.stop()

    # -------------------------------------------------------------------------

    def save_info_files(self):
        if self.opts.info_dir:
            path = self.opts.info_dir
        else:
            dtstr = datetime.datetime.today().strftime('%Y%m%d_%H%M%S')
            path = "sysinfo_%s" % dtstr
        if not os.path.exists(path):
            os.makedirs(path)

        print "Saving system info files into", path

        rabbit_pre = "%s/%s" % (path, "rabbit")
        rabbit_info = self.sysinfo.get("rabbit", None)
        self._save_file(rabbit_pre, "overview", rabbit_info)
        self._save_file(rabbit_pre, "queues", rabbit_info)
        self._save_file(rabbit_pre, "connections", rabbit_info)
        self._save_file(rabbit_pre, "exchanges", rabbit_info)
        self._save_file(rabbit_pre, "bindings", rabbit_info)

        db_pre = "%s/%s" % (path, "db")
        db_info = self.sysinfo.get("db", None)
        self._save_file(db_pre, "resources", db_info)
        self._save_file(db_pre, "directory", db_info)

        cei_pre = "%s/%s" % (path, "cei")
        cei_info = self.sysinfo.get("cei", None)
        self._save_file(cei_pre, "zoo", cei_info)

    def _save_file(self, prefix, part, content):
        if not content:
            return
        if part not in content:
            return
        part_content = content[part]
        filename = "%s_%s.json" % (prefix, part)
        json_content = json.dumps(part_content)
        with open(filename, "w") as f:
            f.write(json_content)
        print " ...saved %s (%s bytes)" % (filename, len(json_content))

    def read_info_files(self):
        path = self.opts.info_dir
        print "Reading system info files from", path

        rabbit_pre = "%s/%s" % (path, "rabbit")
        rabbit_info = self.sysinfo.setdefault("rabbit", {})
        self._read_file(rabbit_pre, "overview", rabbit_info)
        self._read_file(rabbit_pre, "queues", rabbit_info)
        self._read_file(rabbit_pre, "connections", rabbit_info)
        self._read_file(rabbit_pre, "exchanges", rabbit_info)
        self._read_file(rabbit_pre, "bindings", rabbit_info)

        db_pre = "%s/%s" % (path, "db")
        db_info = self.sysinfo.setdefault("db", {})
        self._read_file(db_pre, "resources", db_info)
        self._read_file(db_pre, "directory", db_info)

        cei_pre = "%s/%s" % (path, "cei")
        cei_info = self.sysinfo.setdefault("cei", {})
        self._read_file(cei_pre, "zoo", cei_info)

    def _read_file(self, prefix, part, content):
        if content is None:
            return
        filename = "%s_%s.json" % (prefix, part)
        if not os.path.exists(filename):
            return
        with open(filename, "r") as f:
            json_content = f.read()
            content[part] = json.loads(json_content)
        print " ...loaded %s (%s bytes)" % (filename, len(json_content))

    # -------------------------------------------------------------------------

    def diagnose(self):
        print "-----------------------------------------------------"
        self._analyze()

        if "R" in self.opts.only_do.upper():
            self._diag_rabbit()

        if "D" in self.opts.only_do.upper():
            self._diag_db()

        if "C" in self.opts.only_do.upper():
            self._diag_cei()

    def _analyze(self):
        print "Analyzing system info"
        self._res_by_type = {}
        self._res_by_id = self.sysinfo.get("db", {}).get("resources", {})
        if self._res_by_id:
            for res in self._res_by_id.values():
                self._res_by_type.setdefault(res.get("type_", "?"), []).append(res)
        self._services = {str(res["name"]) for res in self._res_by_type.get("ServiceDefinition", {})}
        print " ...found %s services in RR" % len(self._services)

        self._agents = {}
        self._agent_by_resid = {}
        directory = self.sysinfo.get("db", {}).get("directory", None)
        if directory:
            for de in directory.values():
                if de["parent"] == "/Agents":
                    attrs = de["attributes"]
                    agent_type = "?"
                    agent_name = attrs.get("name", "")
                    resource_id = attrs.get("resource_id", "")
                    if agent_name.startswith("eeagent"):
                        agent_type = "EEAgent"
                    elif agent_name.startswith("haagent"):
                        agent_type = "HAAgent"
                    elif "ExternalDatasetAgent" in agent_name:
                        agent_type = "DatasetAgent"
                    elif "InstrumentAgent" in agent_name:
                        agent_type = "InstrumentAgent"
                    elif "PlatformAgent" in agent_name:
                        agent_type = "PlatformAgent"
                    if de["key"] in self._agents:
                        self._warn("dir", 2, "Agent %s multiple times in directory", de["key"])
                    self._agents[de["key"]] = dict(key=de["key"], agent_name=agent_name, agent_type=agent_type)
                    if resource_id and resource_id in self._res_by_id:
                        self._agent_by_resid[resource_id] = de["key"]
            print " ...found %s agents in directory (%s for resources)" % (len(self._agents), len(self._agent_by_resid))

    def _diag_rabbit(self):
        print "-----------------------------------------------------"
        print "Analyzing RabbitMQ info..."
        queues = self.sysinfo.get("rabbit", {}).get("queues", {})
        if not queues:
            return
        named_queues = [q for q in queues if not q["name"].startswith("amq")]
        named_queues_cons = [q for q in named_queues if q["consumers"]]
        print " ...found %s named queues (%s with consumers)" % (len(named_queues), len(named_queues_cons))

        anon_queues = [q for q in queues if q["name"].startswith("amq")]
        anon_queues_cons = [q for q in anon_queues if q["consumers"]]
        print " ...found %s anonymous queues (%s with consumers)" % (len(anon_queues), len(anon_queues_cons))

        # Check service queues
        service_queues = [q for q in named_queues if q["name"].split(".", 1)[-1] in self._services]
        service_queues_cons = [q for q in service_queues if q["consumers"]]
        print " ...found %s service queues (%s with consumers)" % (len(service_queues), len(service_queues_cons))
        for q in service_queues:
            if not q["consumers"]:
                self._err("rabbit.svc_queue", 2, "service queue %s has %s consumers", q["name"], q["consumers"])
            elif self.opts.verbose:
                print "  service queue %s: %s consumers" % (q["name"], q["consumers"])

        # Check agent process id queues
        agent_queues = [q for q in named_queues if q["name"].split(".", 1)[-1] in self._agents]
        agent_queues_cons = [q for q in agent_queues if q["consumers"]]
        print " ...found %s agent pid queues (%s with consumers)" % (len(agent_queues), len(agent_queues_cons))
        for q in agent_queues:
            if not q["consumers"]:
                agent_key = q["name"].split(".", 1)[-1]
                self._warn("rabbit.apid_queue", 2, "agent pid queue %s (%s, %s) has %s consumers", q["name"],
                           self._agents[agent_key]["agent_type"], self._agents[agent_key]["agent_name"], q["consumers"])

        # Check agent device id queues
        agent_queues = [q for q in named_queues if q["name"].split(".", 1)[-1] in self._agent_by_resid]
        agent_queues_cons = [q for q in agent_queues if q["consumers"]]
        print " ...found %s agent rid queues (%s with consumers)" % (len(agent_queues), len(agent_queues_cons))
        for q in agent_queues:
            if not q["consumers"]:
                agent_key = self._agent_by_resid[q["name"].split(".", 1)[-1]]
                self._warn("rabbit.arid_queue", 2, "agent rid queue %s (%s, %s) has %s consumers", q["name"],
                           self._agents[agent_key]["agent_type"], self._agents[agent_key]["agent_name"], q["consumers"])

        #pprint.pprint(sorted(q["name"] for q in named_queues))

        # TODO: Check service workers against launch plan (HOW??)

    def _diag_db(self):
        print "-----------------------------------------------------"
        print "Analyzing DB info..."
        print " (TBD)"

    def _diag_cei(self):
        print "-----------------------------------------------------"
        print "Analyzing CEI info..."
        self._zoo_parents = {}
        self._epus = {}
        self._epuis = {}
        self._ees = {}
        self._allprocs = {}
        self._procs = {}
        self._oldprocs = {}
        self._badprocs = {}
        self._proc_by_type = {}
        self._proc_by_epu = {}
        self._proc_by_epui = {}
        zoo = self.sysinfo.get("cei", {}).get("zoo", None)
        self._zoo = zoo
        if not zoo:
            return
        zoo_parents = {}
        for key, entry in zoo.iteritems():
            par, loc = key.rsplit("/", 1)
            zoo_parents.setdefault(par, []).append(key)
        self._zoo_parents = zoo_parents

        sys_key = "/" + self.sysname
        epum_key = sys_key + "/epum/domains/cc"
        for epu in self._zoo_parents.get(epum_key, []):
            epu_data = zoo[epu]
            epu_name = epu.rsplit("/", 1)[-1]
            epu_entry = dict(name=epu_name,
                             num_vm=epu_data.get("engine_conf", {}).get("preserve_n", 0),
                             num_cc=epu_data.get("engine_conf", {}).get("provisioner_vars", {}).get("replicas", 0),
                             num_proc=epu_data.get("engine_conf", {}).get("provisioner_vars", {}).get("slots", 0))
            epu_entry["max_slots"] = epu_entry["num_vm"]*epu_entry["num_cc"]*epu_entry["num_proc"]
            self._epus[epu_name] = epu_entry
            for epui in self._zoo_parents.get(epu + "/instances", []):
                epui_data = zoo[epui]
                epui_name = epui.rsplit("/", 1)[-1]
                epui_entry = dict(name=epui_name,
                                  epu=epu_name,
                                  public_ip=epui_data["public_ip"],
                                  hostname=epui_data["hostname"],
                                  state=epui_data["state"],
                                  max_slots=epu_entry["num_cc"]*epu_entry["num_proc"])
                #print "  EPUI %s: %s %s" % (epui_entry["name"], epui_entry["public_ip"], epui_entry["state"], )
                if epui_entry["state"] == "600-RUNNING":
                    self._epuis[epui_name] = epui_entry
                    epu_entry.setdefault("instances", {})[epui_name] = epui_entry
                else:
                    self._warn("cei.epu_state", 2, "EPU instance %s state: %s", epui_name, epui_entry["state"])

            print " EPU %s: %s VM, %s CC, %s Proc. %s slots, %s running instances" % (epu_entry["name"], epu_entry["num_vm"],
                                                               epu_entry["num_cc"], epu_entry["num_proc"], epu_entry["max_slots"],
                                                               len(epu_entry.get("instances", {})))

        total_ee_procs = 0
        procs_in_ee = []
        pd_ee_key = sys_key + "/pd/resources"
        for ee in self._zoo_parents.get(pd_ee_key, []):
            ee_data = zoo[ee]
            ee_name = ee_data["resource_id"]
            ee_entry = dict(name=ee_name, node_id=ee_data["node_id"], state=ee_data["state"],
                            epu=self._epuis[ee_data["node_id"]]["epu"],
                            hostname=self._epuis[ee_data["node_id"]]["hostname"],
                            num_procs=len(ee_data["assigned"]))
            self._ees[ee_name] = ee_entry
            if ee_entry["state"] != "OK":
                self._warn("cei.ee_state", 2, "EE %s state: %s", ee_name, ee_entry["state"])
            if not ee_data["assigned"]:
                self._warn("cei.ee_assign", 2, "EE %s %s/%s (%s) has no processes (state %s)", ee_name, ee_entry["epu"], ee_entry["node_id"], ee_entry["hostname"], ee_entry["state"])
            total_ee_procs += len(ee_data["assigned"])
            procs_in_ee.extend(x[1] for x in ee_data["assigned"])

        print " Number of EE: %s, total processes: %s" % (len(self._ees), total_ee_procs)
        if len(procs_in_ee) != len(set(procs_in_ee)):
            self._warn("cei.ee_procs", 1, "Process to EE assignment not unique")

        pd_procs_key = sys_key + "/pd/processes"
        for proc in self._zoo_parents.get(pd_procs_key, []):
            proc_data = zoo[proc]
            proc_id = proc_data["upid"]
            ee_data = self._ees.get(proc_data["assigned"], {})
            proc_entry = dict(upid=proc_id, ee=proc_data["assigned"], name=proc_data["name"], num_starts=proc_data["starts"],
                              restart_mode=proc_data["restart_mode"], queueing_mode=proc_data["queueing_mode"],
                              state=proc_data["state"],
                              node_id=ee_data.get("node_id", ""),
                              epu=ee_data.get("epu", ""),
                              hostname=ee_data.get("hostname", ""))
            if proc_entry["state"] == "500-RUNNING":
                self._procs[proc_id] = proc_entry
                self._proc_by_epui.setdefault(ee_data["node_id"], []).append(proc_id)
                self._proc_by_epu.setdefault(ee_data["epu"], []).append(proc_id)
            elif proc_entry["state"] in {"700-TERMINATED", "800-EXITED"}:
                self._oldprocs[proc_id] = proc_entry
            else:
                self._badprocs[proc_id] = proc_entry
            self._allprocs[proc_id] = proc_entry

            if proc_entry["name"].startswith("haagent"):
                self._proc_by_type.setdefault("ha_agent", []).append(proc_id)
            elif proc_entry["name"].startswith("ingestion_worker_process"):
                self._proc_by_type.setdefault("ingest_worker", []).append(proc_id)
            elif proc_entry["name"].startswith("qc_post_processor"):
                self._proc_by_type.setdefault("qc_worker", []).append(proc_id)
            elif proc_entry["name"].startswith("lightweight_pydap"):
                self._proc_by_type.setdefault("pydap", []).append(proc_id)
            elif proc_entry["name"].startswith("vis_user_queue_monitor"):
                self._proc_by_type.setdefault("vis_user_queue_monitor", []).append(proc_id)
            elif proc_entry["name"].startswith("registration_worker"):
                self._proc_by_type.setdefault("registration_worker", []).append(proc_id)
            elif proc_entry["name"].startswith("event_persister"):
                self._proc_by_type.setdefault("event_persister", []).append(proc_id)
            elif proc_entry["name"].startswith("notification_worker_process"):
                self._proc_by_type.setdefault("notification_worker", []).append(proc_id)
            elif proc_entry["name"].startswith("HIGHCHARTS"):
                self._proc_by_type.setdefault("rt_viz", []).append(proc_id)
            elif proc_entry["name"].split("-", 1)[0] in self._services:
                self._proc_by_type.setdefault("svc_worker", []).append(proc_id)
            elif "InstrumentAgent" in proc_id:
                self._proc_by_type.setdefault("instrument_agent", []).append(proc_id)
            elif "PlatformAgent" in proc_id:
                self._proc_by_type.setdefault("platform_agent", []).append(proc_id)
            elif "ExternalDatasetAgent" in proc_id:
                self._proc_by_type.setdefault("dataset_agent", []).append(proc_id)
            elif "bootstrap" in proc_entry["name"]:
                self._proc_by_type.setdefault("bootstrap", []).append(proc_id)
            else:
                print "  Cannot categorize process %s %s" % (proc_id, proc_entry["name"])

        print " ...found %s EPUs, %s EEs, %s processes" % (len(self._epus), len(self._ees), len(self._procs))

        unaccounted_procs = set(procs_in_ee) - set(self._procs.keys()) - set(self._badprocs.keys())
        if unaccounted_procs:
            self._warn("cei.pd_procs", 1, "Unaccounted for processes: %s", unaccounted_procs)

        for ptype in sorted(self._proc_by_type.keys()):
            procs = self._proc_by_type[ptype]
            ok_procs = [True for pid in procs if pid in self._procs]
            proc_by_state = {}
            [proc_by_state.setdefault(self._badprocs[pid]["state"], []).append(pid) for pid in procs if pid in self._badprocs]
            [proc_by_state.setdefault(self._oldprocs[pid]["state"], []).append(pid) for pid in procs if pid in self._oldprocs]
            proc_state = ", ".join(["%s: %s" % (pst, len(proc_by_state[pst])) for pst in sorted(proc_by_state.keys())])
            print " Process type %s: 500-RUNNING: %s, %s (%s total)" % (ptype, len(ok_procs), proc_state, len(procs))
            for pst in sorted(proc_by_state.keys()):
                if pst in {"500-RUNNING", "700-TERMINATED", "800-EXITED"}:
                    continue
                procs1 = proc_by_state[pst]
                for pid in procs1:
                    proc_data = self._allprocs[pid]
                    self._warn("cei.proc_state", 2, "Proc %s on %s/%s %s state: %s", pid, proc_data["epu"], proc_data["node_id"], proc_data["hostname"], pst)

        # Check EPU slots vs. used
        for epu in sorted(self._proc_by_epu.keys()):
            epu_procs = self._proc_by_epu[epu]
            epu_data = self._epus[epu]
            print " EPU %s: %s total, %s used" % (epu, epu_data["max_slots"], len(epu_procs))

            for epui in sorted(epu_data["instances"]):
                if epui in self._proc_by_epui:
                    epui_procs = self._proc_by_epui[epui]
                    epui_data = self._epuis[epui]
                    print "  EPU instance %s: %s total, %s used" % (epui, epui_data["max_slots"], len(epui_procs))
                else:
                    epui_data = self._epuis[epui]
                    self._warn("cei.epu_procs", 2, "EPU instance %s (%s, state=%s) has no processes", epui,
                               epui_data["hostname"], epui_data["state"])

    def print_summary(self):
        print "-----------------------------------------------------"
        print "SUMMARY"
        print " Number of ERR: %s" % len([m for m in self.msgs if m[2] == "ERR"])
        print " Number of WARN: %s" % len([m for m in self.msgs if m[2] == "WARN"])

    def _debug(self, category, indent, msg, *args, **kwargs):
        self._logmsg(category, indent, "DEBUG", msg, *args, **kwargs)

    def _info(self, category, indent, msg, *args, **kwargs):
        self._logmsg(category, indent, "INFO", msg, *args, **kwargs)

    def _warn(self, category, indent, msg, *args, **kwargs):
        self._logmsg(category, indent, "WARN", msg, *args, **kwargs)

    def _err(self, category, indent, msg, *args, **kwargs):
        self._logmsg(category, indent, "ERR", msg, *args, **kwargs)

    COLOR_MAP = {"ERR": 31, "WARN": 33}

    def _logmsg(self, category, indent, level, msg, *args, **kwargs):
        if level and level in {"WARN", "ERR"}:
            prefix = (" "*indent) + level + ": "
        else:
            prefix = (" "*indent)
        if "%" in msg:
            msgstr = prefix + msg % args
        elif args:
            msgstr = prefix + msg + " " + " ".join(args)
        else:
            msgstr = prefix + msg
        self.msgs.append((category, indent, level, msgstr))

        # Print output
        color = self.COLOR_MAP.get(level, "")
        if color:
            msgstr = "\033[1m\033[%sm%s\033[0m" % (color, msgstr)

        if self.opts.level == "CRIT":
            if level in ("ERR", "CRIT"):
                print msgstr
        elif self.opts.level == "ERR":
            if level == "ERR":
                print msgstr
        else:
            print msgstr

    def _errout(self, msg=None):
        if msg:
            print "FAIL:", msg
        sys.exit(1)

    def start(self):
        self.init_args()
        self.read_config()
        if self.opts.load_info:
            if not self.opts.info_dir or not os.path.exists(self.opts.info_dir):
                self._errout("Path %s does not exist" % self.opts.info_dir)
            self.read_info_files()

        else:
            self.get_system_info()
            if not self.opts.no_save:
                self.save_info_files()

        self.diagnose()

        self.print_summary()

        if self.opts.interactive:
            from IPython import embed
            embed()

def entry():
    diag = IonDiagnose()
    diag.start()

if __name__ == '__main__':
    entry()
