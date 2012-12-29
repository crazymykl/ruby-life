#! /bin/env ruby

require 'gosu'
module RubyLife
  SIZE = 4
  class LifeWindow < Gosu::Window
    attr_accessor :board

    def initialize width=300, height=200
      @board = Board.new width, height
      super(width*SIZE, height*SIZE, false)
    end

    def show
      self.caption = @board.characteristics
      @board.randomize
      super
    end

    def update
      @board.evolve
    end

    def draw
      @board.cells.each_with_index do |val, i|
        draw_square i % @board.width, i / @board.width if val
      end
    end

    def draw_square x, y, c=Gosu::Color::GREEN
      draw_quad x*SIZE, y*SIZE, c, (x+1)*SIZE, y*SIZE, c,
                x*SIZE, (y+1)*SIZE, c, (x+1)*SIZE, (y+1)*SIZE, c
    end
  end
end
