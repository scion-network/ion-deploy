from rabbithelper import clean_by_sysname
import sys

connect_string = ' '.join(sys.argv[1:])
deleted_exchanges, deleted_queues = clean_by_sysname(connect_string, '')

print('Deleted exchanges:\n%s \n' % '\n'.join(deleted_exchanges))
print('Deleted queues:\n%s \n' % '\n'.join(deleted_queues))

