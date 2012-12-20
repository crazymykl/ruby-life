#! /bin/env ruby

require 'ruby-life/board'

def run_tty
  h, w = begin
    require 'terminfo'
    TermInfo.screen_size
  rescue LoadError
    [20, 80]
  end

  b = Board.new(w, h-2)
  b.randomize
  b.run
end

if __FILE__ == $0
  run_tty
end

