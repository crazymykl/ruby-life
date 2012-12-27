require 'inline'

class Board
  attr_reader :cells, :generation, :width, :height, :births, :survivors, :running

  def initialize width, height, births=[3], survivors=[2,3]
    @width = width
    @height = height
    @survivors = survivors
    @births = births
    @generation = 0
    @cells = Array.new(width*height, false)
    @urnning = false
  end

  def [] x, y
    @cells[@height*y+x]
  end

  def []= x, y, value
    @cells[@height*y+x] = value
  end

  def live_neighbors x, y
    neighbors = [[x-1, y-1], [x, y-1], [x+1, y-1],
                 [x-1, y  ],           [x+1, y  ],
                 [x-1, y+1], [x, y+1], [x+1, y+1]]
    neighbors.map { |p| point_live? *p }.count true
  end

  def point_live? x, y
    in_bounds?(x, y) and self[x,y]
  end

  def flip x, y
    self[x,y]= !point_live?(x, y)
  end

  def characteristics
    "#{@width}x#{@height} B#{@births.join}/S#{@survivors.join}"
  end

  def to_s live='*', dead='.'
    board = @cells.each_slice(@width).map do |line|
      line.map { |cell| cell ? live : dead }.join
    end.unshift(characteristics).join "\n"
  end

  begin
    require 'inline'
    inline do |builder|
      builder.prefix "#define BOUNDS(x) ((x > 0 && x < len) ? RTEST(src_brd[x]) : 0)"
      builder.prefix "#define RBOOL(cond) ((cond) ? Qtrue : Qfalse)"
      builder.prefix "#define ALIVENESS(x) ((RTEST(src_brd[x])) ? live : born)"
      builder.add_link_flags "-lruby19"
      builder.c_raw %q{
        static VALUE evolve(int argc, VALUE *argv, VALUE self) {
          long int w = FIX2INT(rb_ivar_get(self, rb_intern("@width")));
          VALUE brd = rb_ivar_get(self, rb_intern("@cells"));
          VALUE births = rb_ivar_get(self, rb_intern("@births"));
          VALUE survivors = rb_ivar_get(self, rb_intern("@survivors"));
          VALUE *src_brd = RARRAY_PTR(brd);
          VALUE *b_ptr = RARRAY_PTR(births), *s_ptr = RARRAY_PTR(survivors);
          int i, len = RARRAY_LEN(brd), b_len = RARRAY_LEN(births),
            s_len = RARRAY_LEN(survivors);
          VALUE dst_brd = rb_ary_new2(len);
          unsigned int born = 0, live = 0;

          for(i=0; i<b_len; ++i)
            born |= 1 << FIX2INT(b_ptr[i]);

          born &= 0xff;

          for(i=0; i<s_len; ++i)
            live |= 1 << FIX2INT(s_ptr[i]);

          live &= 0xff;

          for(i=0; i<len; ++i) {
            int neighbors = BOUNDS(i-w) + BOUNDS(i+w);

            if(i % w)
              neighbors += BOUNDS(i-w-1) + BOUNDS(i+w-1) + BOUNDS(i-1);

            if((i+1) % w)
              neighbors += BOUNDS(i+w+1) + BOUNDS(i-w+1) + BOUNDS(i+1);

            rb_ary_push(dst_brd, RBOOL(ALIVENESS(i) & (1 << neighbors)));
          }
          rb_ivar_set(self, rb_intern("@cells"), dst_brd);
          return self;
        }
      }, method_name: 'evolve'
    end
  rescue LoadError => e
    p "Falling back to legacy implementation: #{e}"
    def evolve
      next_board = Array.new(@width*@height)
      @width.times do |x|
        @height.times do |y|
          aliveness = self[x,y] ? @survivors : @births
          next_board[@height*y+x] = aliveness.include? live_neighbors(x, y)
        end
      end
      @cells = next_board
      @generation += 1
      self
    end
  end

  def randomize p=0.5
    @cells = @cells.map { rand <= p }
    self
  end

  def run steps=Float::INFINITY, delay=1/60.0
    @running = true
    while @running
      begin
        @running = (steps -= 1) > 0
        puts "\e[H\e[2J#{evolve}"
        sleep delay
      rescue Interrupt
        @running = false
      end
    end
  end

  def in_bounds? x, y
    (0...@height) === y and (0...@width) === x
  end
end
