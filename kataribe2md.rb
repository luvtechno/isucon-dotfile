#!/usr/bin/env ruby

txt = $stdin.read

val = txt.split("\n\n").map { |txt|
  header = txt.lines.first
  body = txt.lines[1..-1]

  ["\n\n### #{header}", "\n", "```\n", body, "\n```\n"].join
}.join

puts val
