require 'daemons'

# Run Torrent sync as a daemon
Daemons.run('listener.rb')

