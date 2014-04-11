# TODO exceptions on the file scope cannot be handled in OSX 10.6
osx_32bit = OSX_VERSION && BITS == 32
unless osx_32bit
  begin
    ThisConstDoesSoNotExist
  rescue Object => e
    $file_scope_exception = e
  end

  class TestClassScopeExceptions
    def self.foo(arg1, arg2)
    end

    begin
      foo(:too_few_args)
    rescue Object => e
      $class_scope_exception = e
    end
  end
end

describe "An exception" do
  it "includes backtrace info when raised from a file scope", :unless => osx_32bit do
    $file_scope_exception.backtrace.first.should.match /exception_spec\.rb:2/
  end

  it "includes backtrace info when raised from a class scope", :unless => osx_32bit do
    $class_scope_exception.backtrace.first.should.match /exception_spec\.rb:12/
  end
end

describe "NSExceptions" do
  it "can be caught (1)", :unless => osx_32bit do
    exc_name = 'TestException'
    exc_reason = 'some reason'
    exc_userInfo = { 'One' => 1, 'Two' => 2, 'Three' => 3}
    begin
      NSException.exceptionWithName(exc_name, reason:exc_reason, userInfo:exc_userInfo).raise
    rescue => e
      e.name.should == exc_name
      e.reason.should == exc_reason
      e.userInfo.should == exc_userInfo
    end
  end

  it "can be caught (2)", :unless => osx_32bit do
    begin
      NSString.stringWithString(42)
    rescue => e
      e.class.should == NSException
      e.name.should == 'NSInvalidArgumentException'
    end
  end

  it "should be raised with Kernel.raise", :unless => osx_32bit do
    begin
      raise NSException.exceptionWithName('NSInvalidArgumentException', reason:'Woops!', userInfo:nil)
    rescue => e
      e.class.should == NSException
      e.name.should == 'NSInvalidArgumentException'
    end
  end
end
