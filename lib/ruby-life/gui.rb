#! /bin/env ruby

require 'ruby-life/board'
require 'gosu'
SIZE = 4

class LifeWindow < Gosu::Window

  def initialize width=200, height=150
    @board = Board.new width, height
    super(width*SIZE, height*SIZE, false)
  end

  def show
    @board.randomize
    super
  end

  def update
    @board.evolve
  end

  def draw
    @board.width.times do |x|
      @board.height.times do |y|
        draw_square x,y if @board[x,y]
      end
    end
  end

  def draw_square x, y, c=Gosu::Color::GREEN
    draw_quad x*SIZE, y*SIZE, c, (x+1)*SIZE, y*SIZE, c,
              x*SIZE, (y+1)*SIZE, c, (x+1)*SIZE, (y+1)*SIZE, c
  end
end

LifeWindow.new.show
