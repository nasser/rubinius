require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes.rb', __FILE__)

describe "String#index with object" do
  it "raises a TypeError if obj isn't a String, Fixnum or Regexp" do
    lambda { "hello".index(:sym)      }.should raise_error(TypeError)
    lambda { "hello".index(mock('x')) }.should raise_error(TypeError)
  end

  it "doesn't try to convert obj to an Integer via to_int" do
    obj = mock('x')
    lambda { "hello".index(obj) }.should raise_error(TypeError)
  end

  it "tries to convert obj to a string via to_str" do
    obj = mock('lo')
    obj.should_receive(:to_str).and_return("lo")
    "hello".index(obj).should == "hello".index("lo")
  end
end

ruby_version_is ""..."1.9" do
  describe "String#index with Fixnum" do
    it "returns the index of the first occurrence of the given character" do
      "hello".index(?e).should == 1
      "hello".index(?l).should == 2
    end

    it "character values over 255 (256th ASCII character) always result in nil" do
      # A naive implementation could try to use % 256
      "hello".index(?e + 256 * 3).should == nil
    end

    it "negative character values always result in nil" do
      # A naive implementation could try to use % 256
      "hello".index(-(256 - ?e)).should == nil
    end

    it "starts the search at the given offset" do
      "blablabla".index(?b, 0).should == 0
      "blablabla".index(?b, 1).should == 3
      "blablabla".index(?b, 2).should == 3
      "blablabla".index(?b, 3).should == 3
      "blablabla".index(?b, 4).should == 6
      "blablabla".index(?b, 5).should == 6
      "blablabla".index(?b, 6).should == 6

      "blablabla".index(?a, 0).should == 2
      "blablabla".index(?a, 2).should == 2
      "blablabla".index(?a, 3).should == 5
      "blablabla".index(?a, 4).should == 5
      "blablabla".index(?a, 5).should == 5
      "blablabla".index(?a, 6).should == 8
      "blablabla".index(?a, 7).should == 8
      "blablabla".index(?a, 8).should == 8
    end

    it "starts the search at offset + self.length if offset is negative" do
      str = "blablabla"

      [?a, ?b].each do |needle|
        (-str.length .. -1).each do |offset|
          str.index(needle, offset).should ==
          str.index(needle, offset + str.length)
        end
      end

      "blablabla".index(?b, -9).should == 0
    end

    it "returns nil if offset + self.length is < 0 for negative offsets" do
      "blablabla".index(?b, -10).should == nil
      "blablabla".index(?b, -20).should == nil
    end

    it "returns nil if the character isn't found" do
      "hello".index(0).should == nil

      "hello".index(?H).should == nil
      "hello".index(?z).should == nil
      "hello".index(?e, 2).should == nil

      "blablabla".index(?b, 7).should == nil
      "blablabla".index(?b, 10).should == nil

      "blablabla".index(?a, 9).should == nil
      "blablabla".index(?a, 20).should == nil
    end

    it "converts start_offset to an integer via to_int" do
      obj = mock('1')
      obj.should_receive(:to_int).and_return(1)
      "ROAR".index(?R, obj).should == 3
    end
  end
end

describe "String#index with String" do
  it "behaves the same as String#index(char) for one-character strings" do
    ["blablabla", "hello cruel world...!"].each do |str|
      str.split("").uniq.each do |str|
        chr = str[0]
        str.index(str).should == str.index(chr)

        0.upto(str.size + 1) do |start|
          str.index(str, start).should == str.index(chr, start)
        end

        (-str.size - 1).upto(-1) do |start|
          str.index(str, start).should == str.index(chr, start)
        end
      end
    end
  end

  it "returns the index of the first occurrence of the given substring" do
    "blablabla".index("").should == 0
    "blablabla".index("b").should == 0
    "blablabla".index("bla").should == 0
    "blablabla".index("blabla").should == 0
    "blablabla".index("blablabla").should == 0

    "blablabla".index("l").should == 1
    "blablabla".index("la").should == 1
    "blablabla".index("labla").should == 1
    "blablabla".index("lablabla").should == 1

    "blablabla".index("a").should == 2
    "blablabla".index("abla").should == 2
    "blablabla".index("ablabla").should == 2
  end

  it "doesn't set $~" do
    $~ = nil

    'hello.'.index('ll')
    $~.should == nil
  end

  it "ignores string subclasses" do
    "blablabla".index(StringSpecs::MyString.new("bla")).should == 0
    StringSpecs::MyString.new("blablabla").index("bla").should == 0
    StringSpecs::MyString.new("blablabla").index(StringSpecs::MyString.new("bla")).should == 0
  end

  it "starts the search at the given offset" do
    "blablabla".index("bl", 0).should == 0
    "blablabla".index("bl", 1).should == 3
    "blablabla".index("bl", 2).should == 3
    "blablabla".index("bl", 3).should == 3

    "blablabla".index("bla", 0).should == 0
    "blablabla".index("bla", 1).should == 3
    "blablabla".index("bla", 2).should == 3
    "blablabla".index("bla", 3).should == 3

    "blablabla".index("blab", 0).should == 0
    "blablabla".index("blab", 1).should == 3
    "blablabla".index("blab", 2).should == 3
    "blablabla".index("blab", 3).should == 3

    "blablabla".index("la", 1).should == 1
    "blablabla".index("la", 2).should == 4
    "blablabla".index("la", 3).should == 4
    "blablabla".index("la", 4).should == 4

    "blablabla".index("lab", 1).should == 1
    "blablabla".index("lab", 2).should == 4
    "blablabla".index("lab", 3).should == 4
    "blablabla".index("lab", 4).should == 4

    "blablabla".index("ab", 2).should == 2
    "blablabla".index("ab", 3).should == 5
    "blablabla".index("ab", 4).should == 5
    "blablabla".index("ab", 5).should == 5

    "blablabla".index("", 0).should == 0
    "blablabla".index("", 1).should == 1
    "blablabla".index("", 2).should == 2
    "blablabla".index("", 7).should == 7
    "blablabla".index("", 8).should == 8
    "blablabla".index("", 9).should == 9
  end

  it "starts the search at offset + self.length if offset is negative" do
    str = "blablabla"

    ["bl", "bla", "blab", "la", "lab", "ab", ""].each do |needle|
      (-str.length .. -1).each do |offset|
        str.index(needle, offset).should ==
        str.index(needle, offset + str.length)
      end
    end
  end

  it "returns nil if the substring isn't found" do
    "blablabla".index("B").should == nil
    "blablabla".index("z").should == nil
    "blablabla".index("BLA").should == nil
    "blablabla".index("blablablabla").should == nil
    "blablabla".index("", 10).should == nil

    "hello".index("he", 1).should == nil
    "hello".index("he", 2).should == nil
  end

  it "converts start_offset to an integer via to_int" do
    obj = mock('1')
    obj.should_receive(:to_int).and_return(1)
    "RWOARW".index("RW", obj).should == 4
  end
end

describe "String#index with Regexp" do
  it "behaves the same as String#index(string) for escaped string regexps" do
    ["blablabla", "hello cruel world...!"].each do |str|
      ["", "b", "bla", "lab", "o c", "d."].each do |needle|
        regexp = Regexp.new(Regexp.escape(needle))
        str.index(regexp).should == str.index(needle)

        0.upto(str.size + 1) do |start|
          str.index(regexp, start).should == str.index(needle, start)
        end

        (-str.size - 1).upto(-1) do |start|
          str.index(regexp, start).should == str.index(needle, start)
        end
      end
    end
  end

  it "returns the index of the first match of regexp" do
    "blablabla".index(/bla/).should == 0
    "blablabla".index(/BLA/i).should == 0

    "blablabla".index(/.{0}/).should == 0
    "blablabla".index(/.{6}/).should == 0
    "blablabla".index(/.{9}/).should == 0

    "blablabla".index(/.*/).should == 0
    "blablabla".index(/.+/).should == 0

    "blablabla".index(/lab|b/).should == 0

    "blablabla".index(/\A/).should == 0
    "blablabla".index(/\Z/).should == 9
    "blablabla".index(/\z/).should == 9
    "blablabla\n".index(/\Z/).should == 9
    "blablabla\n".index(/\z/).should == 10

    "blablabla".index(/^/).should == 0
    "\nblablabla".index(/^/).should == 0
    "b\nablabla".index(/$/).should == 1
    "bl\nablabla".index(/$/).should == 2

    "blablabla".index(/.l./).should == 0
  end

  it "sets $~ to MatchData of match and nil when there's none" do
    'hello.'.index(/.(.)/)
    $~[0].should == 'he'

    'hello.'.index(/not/)
    $~.should == nil
  end

  it "starts the search at the given offset" do
    "blablabla".index(/.{0}/, 5).should == 5
    "blablabla".index(/.{1}/, 5).should == 5
    "blablabla".index(/.{2}/, 5).should == 5
    "blablabla".index(/.{3}/, 5).should == 5
    "blablabla".index(/.{4}/, 5).should == 5

    "blablabla".index(/.{0}/, 3).should == 3
    "blablabla".index(/.{1}/, 3).should == 3
    "blablabla".index(/.{2}/, 3).should == 3
    "blablabla".index(/.{5}/, 3).should == 3
    "blablabla".index(/.{6}/, 3).should == 3

    "blablabla".index(/.l./, 0).should == 0
    "blablabla".index(/.l./, 1).should == 3
    "blablabla".index(/.l./, 2).should == 3
    "blablabla".index(/.l./, 3).should == 3

    "xblaxbla".index(/x./, 0).should == 0
    "xblaxbla".index(/x./, 1).should == 4
    "xblaxbla".index(/x./, 2).should == 4

    "blablabla\n".index(/\Z/, 9).should == 9
  end

  it "starts the search at offset + self.length if offset is negative" do
    str = "blablabla"

    ["bl", "bla", "blab", "la", "lab", "ab", ""].each do |needle|
      (-str.length .. -1).each do |offset|
        str.index(needle, offset).should ==
        str.index(needle, offset + str.length)
      end
    end
  end

  it "returns nil if the substring isn't found" do
    "blablabla".index(/BLA/).should == nil

    "blablabla".index(/.{10}/).should == nil
    "blaxbla".index(/.x/, 3).should == nil
    "blaxbla".index(/..x/, 2).should == nil
  end

  it "returns nil if the Regexp matches the empty string and the offset is out of range" do
    "ruby".index(//,12).should be_nil
  end

  it "supports \\G which matches at the given start offset" do
    "helloYOU.".index(/\GYOU/, 5).should == 5
    "helloYOU.".index(/\GYOU/).should == nil

    re = /\G.+YOU/
    # The # marks where \G will match.
    [
      ["#hi!YOUall.", 0],
      ["h#i!YOUall.", 1],
      ["hi#!YOUall.", 2],
      ["hi!#YOUall.", nil]
    ].each do |spec|

      start = spec[0].index("#")
      str = spec[0].delete("#")

      str.index(re, start).should == spec[1]
    end
  end

  it "converts start_offset to an integer via to_int" do
    obj = mock('1')
    obj.should_receive(:to_int).and_return(1)
    "RWOARW".index(/R./, obj).should == 4
  end
end
