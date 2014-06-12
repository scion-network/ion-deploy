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
import yaml
import sys


class IonDiagnose(object):

    def __init__(self):
        self.sysinfo = {}

    def init_args(self):
        print "OOINet iondiag"
        parser = argparse.ArgumentParser(description="OOINet iondiag")
        parser.add_argument('-c', '--config', type=str, help='File path to config file', default=[])
        parser.add_argument('-d', '--info_dir', type=str, help='System info directory')
        parser.add_argument('-l', '--load_info', action='store_true', help="Load from system info directory")
        parser.add_argument('-n', '--no_save', action='store_true', help="Don't store system info")
        parser.add_argument('-v', '--verbose', action='store_true', help="Verbose output")
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

    def get_system_info(self):
        # Read rabbit
        self._get_rabbit_info()

        # Read resources from postgres
        self._get_db_info()

        # Read info from CEIctrl

    def _get_rabbit_info(self):
        import requests
        from requests.auth import HTTPBasicAuth
        mgmt = self.cfg["container"]["exchange"]["management"]
        url_prefix = "http://%s:%s" % (mgmt["host"], mgmt["port"])
        print "Getting RabbitMQ info from %s" % url_prefix
        rabbit_info = self.sysinfo.setdefault("rabbit", {})
        url1 = url_prefix + "/api/overview"
        resp = requests.get(url1, auth=HTTPBasicAuth(mgmt["username"], mgmt["password"]))
        rabbit_info["overview"] = resp.json()
        print " ...retrieved %s overview entries" % (len(rabbit_info["overview"]))

        url2 = url_prefix + "/api/queues"
        resp = requests.get(url2, auth=HTTPBasicAuth(mgmt["username"], mgmt["password"]))
        rabbit_info["queues"] = resp.json()
        print " ...retrieved %s queues" % (len(rabbit_info["queues"]))

        url3 = url_prefix + "/api/connections"
        resp = requests.get(url3, auth=HTTPBasicAuth(mgmt["username"], mgmt["password"]))
        rabbit_info["connections"] = resp.json()
        print " ...retrieved %s connections" % (len(rabbit_info["connections"]))

        url4 = url_prefix + "/api/exchanges"
        resp = requests.get(url4, auth=HTTPBasicAuth(mgmt["username"], mgmt["password"]))
        rabbit_info["exchanges"] = resp.json()
        print " ...retrieved %s exchanges" % (len(rabbit_info["exchanges"]))

        url5 = url_prefix + "/api/bindings"
        resp = requests.get(url5, auth=HTTPBasicAuth(mgmt["username"], mgmt["password"]))
        rabbit_info["bindings"] = resp.json()
        print " ...retrieved %s bindings" % (len(rabbit_info["bindings"]))

    def _get_db_info(self):
        import psycopg2
        from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

        db_info = self.sysinfo.setdefault("db", {})
        pgcfg = self.cfg["server"]["postgresql"]
        db_name = "%s_%s" % (self.sysname.lower(), pgcfg["database"])

        dsn = "host=%s port=%s dbname=%s user=%s password=%s" % (pgcfg["host"], pgcfg["port"], db_name, pgcfg["username"], pgcfg["password"])
        with psycopg2.connect(dsn) as conn:
            print "Getting DB info from PostgreSQL as:", dsn.rsplit("=", 1)[0] + "=***"
            conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
            with conn.cursor() as cur:
                cur.execute("SELECT id,doc FROM ion_resources")
                rows = cur.fetchall()
                resources = {}
                for row in rows:
                    res_id, res_doc = row[0], row[1]
                    resources[res_id] = res_doc
                print " ...retrieved %s resources" % (len(resources))
                db_info["resources"] = resources

                cur.execute("SELECT id,doc FROM ion_resources_dir")
                rows = cur.fetchall()
                dir_entries = {}
                for row in rows:
                    dir_id, dir_doc = row[0], row[1]
                    dir_entries[dir_id] = dir_doc
                print " ...retrieved %s directory entries" % (len(dir_entries))
                db_info["directory"] = dir_entries

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


    def diagnose(self):
        self._analyze()
        self._diag_rabbit()

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
                        print "  WARN: Agent %s multiple times in directory" % de["key"]
                    self._agents[de["key"]] = dict(key=de["key"], agent_name=agent_name, agent_type=agent_type)
                    if resource_id and resource_id in self._res_by_id:
                        self._agent_by_resid[resource_id] = de["key"]
            print " ...found %s agents in directory (%s for resources)" % (len(self._agents), len(self._agent_by_resid))

    def _diag_rabbit(self):
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
                print "  WARN: service queue %s has %s consumers" % (q["name"], q["consumers"])
            elif self.opts.verbose:
                print "  service queue %s: %s consumers" % (q["name"], q["consumers"])

        # Check agent process id queues
        agent_queues = [q for q in named_queues if q["name"].split(".", 1)[-1] in self._agents]
        agent_queues_cons = [q for q in agent_queues if q["consumers"]]
        print " ...found %s agent process id queues (%s with consumers)" % (len(agent_queues), len(agent_queues_cons))
        for q in agent_queues:
            if not q["consumers"]:
                agent_key = q["name"].split(".", 1)[-1]
                print "  WARN: agent process id queue %s (%s, %s) has %s consumers" % (q["name"], self._agents[agent_key]["agent_type"], self._agents[agent_key]["agent_name"], q["consumers"])

        # Check agent device id queues
        agent_queues = [q for q in named_queues if q["name"].split(".", 1)[-1] in self._agent_by_resid]
        agent_queues_cons = [q for q in agent_queues if q["consumers"]]
        print " ...found %s agent device id queues (%s with consumers)" % (len(agent_queues), len(agent_queues_cons))
        for q in agent_queues:
            if not q["consumers"]:
                agent_key = self._agent_by_resid[q["name"].split(".", 1)[-1]]
                print "  WARN: agent device id queue %s (%s, %s) has %s consumers" % (q["name"], self._agents[agent_key]["agent_type"], self._agents[agent_key]["agent_name"], q["consumers"])

        #pprint.pprint(sorted(q["name"] for q in named_queues))

    def _diag_db(self):
        pass

    def _errout(self, msg=None):
        if msg:
            print "ERROR:", msg
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

def entry():
    diag = IonDiagnose()
    diag.start()

if __name__ == '__main__':
    entry()
