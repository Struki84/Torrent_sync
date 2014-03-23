#!/usr/bin/env ruby
require 'terminal-notifier'
require 'listen'
require 'net/scp'
require 'net/HTTP'
require_relative './config.rb'

def host_exists?(server, port)
  http = Net::HTTP.start(server, port, {open_timeout: 5, read_timeout: 5})
  response = http.head("/")
  response.code == "200"
rescue Timeout::Error, SocketError
  false
end

@log = Logger.new("log/main.log", "daily")
@log.datetime_format = "x%F %T"

@host = nil
if host_exists?(@local_host, @port)
	@host = @local_host
else
	@host = @remote_host
end

listener = Listen.to(@local_path) do |modified, added, removed|
	unless added.nil?
		unless @host.nil?
			Net::SCP.start(@host, @username, :password => @password) do |scp|
		  	# upload a file to a remote server
		  	scp.upload! added[0], @remote_path do |ch, name, sent, total|
		  		if sent == total
		  			TerminalNotifier.notify("Torrent file copied to\n#{@host}", :title => 'Torrent sync', :subtitle => 'Torrent download detected')
		  			@log.info "copied #{added[0]} to #{@host}"
		  			puts "#{added[0]}"
		  			@completed = true
		  			@file = added[0]
		  		end
		  	end
		  end
		  # if File.exist?(@file) do
			# 	puts "#{added[0]} exists"
			# 	File.delete(@file)
			# else
			# 	puts "Nemre ga nac"
			# end
		else
			TerminalNotifier.notify("Target host is unavailable!", :title => 'Torrent sync', :subtitle => 'Error while copying torrent file!')
			log.error "Could not connect to target host at: #{@host}"
		end	
	end
end	

Process.daemon
listener.start # not blocking
listener.only %r{.torrent$}
sleep






