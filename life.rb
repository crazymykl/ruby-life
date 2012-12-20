#! /bin/env ruby

require './board'

if __FILE__ == $0
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
