#! /bin/env ruby
require 'gosu'

module RubyLife
  SCALE_FACTOR = 4
  class LifeWindow < Gosu::Window
    attr_accessor :board

    def initialize width=300, height=200
      @board = Board.new width, height
      super(width*SCALE_FACTOR, height*SCALE_FACTOR, false)
    end

    def show
      self.caption = board.characteristics
      board.randomize
      board.running = true
      super
    end

    def button_down btn_id
      case button_id_to_char btn_id
      when 'r'
        board.randomize
      when ' '
        board.running = !board.running
      when 's'
        board.evolve
      when 'c'
        @board = Board.new width, height
      end
      if btn_id == Gosu::MsLeft
        x = (mouse_x/SCALE_FACTOR).floor.to_i
        y = (mouse_y/SCALE_FACTOR).floor.to_i
        board.flip x, y
      end
    end

    def needs_cursor?
      true
    end

    def update
      board.evolve if board.running
    end

    def draw
      board.cells.each_with_index do |val, i|
        draw_square i % board.width, i / board.width if val
      end
    end

    def draw_square x, y, c=Gosu::Color::GREEN
      draw_quad x*SCALE_FACTOR, y*SCALE_FACTOR, c, (x+1)*SCALE_FACTOR, y*SCALE_FACTOR, c,
                x*SCALE_FACTOR, (y+1)*SCALE_FACTOR, c, (x+1)*SCALE_FACTOR, (y+1)*SCALE_FACTOR, c
    end
  end
end
