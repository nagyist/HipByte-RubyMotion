$specs = []
$describe = nil
$expectations_total = 0
$expectations_failures = 0

class ShouldResult < Java::Lang::Object
  def set_object(obj)
    @obj = obj
  end

  def ==(x)
    if @obj != x
      puts "Expectation failed (expected `#{self}' == `#{x}')"
      $expectations_failures += 1
    end
    $expectations_total += 1
  end
end

class Object
  def describe(msg, &block)
    $specs << [msg, block]
  end
 
  def it(msg)
    puts "#{$describe} #{msg}"
    yield
  end

  def should
    res = ShouldResult.new
    res.set_object self
    res
  end

  def mock(obj)
    # XXX we probably should be smarter here.
    obj
  end
end

class MainActivity < Android::App::Activity
  def onCreate(savedInstanceState)
    super
    $specs.each do |ary|
      $describe = ary[0]
      ary[1].call
    end
    puts "Spec suite finished: #{$expectations_total} expectations, #{$expectations_failures} failure(s)."
  end
end
