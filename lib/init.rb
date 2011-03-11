require "rubygems"
require "bundler/setup"

require "json"
require "grape"
require "redis"
require "ohm"
require "ohm/contrib"

$:.unshift File.dirname(__FILE__) + "/../models/"

require "definition"
require "term"
require "user"
require "vote"
