COTS Server
===========================

A basic server implementation using EventMachine and MongoDB. This should allow people in the COTSBots class to quickly send and receive messages between Android-powered robots.

Requires:
-------------------------

    * Ruby 1.9.3
    * Bundler
    * MongoDB (http://mongodb.org)

To Install:
-----------------------

    * Install Ruby 1.9.3
    * Open up a terminal and type: gem install bundler (use sudo on some systems)
    * Clone this repository
    * Move to where you cloned the code and type: bundle install
    * Run the server by typing: ruby server.rb config.yaml
    * Change the options in config.yaml to match your project settings
