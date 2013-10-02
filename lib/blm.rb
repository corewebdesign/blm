#!/bin/env ruby
# encoding: utf-8

require 'htmlentities'

module BLM
	class Document
		def initialize(source)
			coder = HTMLEntities.new
			@source = coder.decode(source.force_encoding("ISO-8859-1").encode("UTF-8"))
		end

		def header
			return @header if defined?(@header)

			@header = {}
			get_contents(@source, "#HEADER#", "#").each_line do |line|
				next if line.empty? || line.blank?
				key, value = line.split(" : ")
				@header[key.downcase.to_sym] = value.gsub(/'/, "").strip
			end
			return @header
		end

		def definition
			return @definition if defined?(@definition)

			@definition = []
			get_contents(@source, "#DEFINITION#", "#").split(header[:eor]).first.split(header[:eof]).each do |field|
				next if field.empty?
				@definition << field.downcase.strip
			end
			return @definition
		end

		def data
			return @data if defined?(@data)

			@data = []
			get_contents(@source, "#DATA#", "#END#").split(header[:eor]).each do |line|
				entry = {}
				line.split(header[:eof]).each_with_index do |field, index|
					entry[definition[index].to_sym] = field.strip
				end
				@data << Row.new(entry)
			end
			return @data
		end

		private
		def get_contents(string, start, finish)
			start = string.index(start) + start.size
			finish = string.index(finish, start) - finish.size
			string[start..finish].strip
		end
	end

	class Row
		attr_accessor :attributes

		def initialize(hash)
			@attributes = hash
		end

		def method_missing(method, *arguments, &block)
			return @attributes[method] unless @attributes[method].nil?
		end
	end
end
