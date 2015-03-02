defmodule ConfigParserTest do
  use ExUnit.Case

  def check_string(string, against_value) do
    assert against_value == ConfigParser.parse_string(string)
  end

  test "parses an empty file" do
    check_string("", {:ok, %{}})
  end

  test "parses an comment only file" do
    check_string("#this is a useless file\n", {:ok, %{}})
  end

  test "parses comments and empty lines" do
    check_string("""
      #this is a useless file

        # filled with comments and empty lines
      """, {:ok, %{}} )
  end

  test "parses a single section" do
    check_string("[section]\n", {:ok, %{"section" => %{}}} )
  end

  test "parses a section name with a space" do
    check_string("[section with space]\n", {:ok, %{"section with space" => %{}}} )
  end

  test "parses a config option into a section" do
    check_string("""
      [section]
      # this is an interesting key value pair
      key = value
      """, {:ok, %{"section" => %{"key" => "value"}}} )
  end

  test "allows spaces in the keys" do
    check_string("""
      [section]
      # this is an interesting key value pair
      spaces in keys=allowed
      """, {:ok, %{"section" => %{"spaces in keys" => "allowed"}}} )
  end

  test "allows spaces in the values" do
    check_string("""
      [section]
      # this is an interesting key value pair
      spaces in values=allowed as well
      """, {:ok, %{"section" => %{"spaces in values" => "allowed as well"}}} )
  end

  test "allows spaces around the delimiter" do
    check_string("""
      [section]
      # this is an interesting key value pair
      spaces around the delimiter = obviously
      """, {:ok, %{"section" => %{"spaces around the delimiter" => "obviously"}}} )
  end

  test "allows a colon as the delimiter" do
    check_string("""
      [section]
      # this is an interesting key value pair
      you can also use : to delimit keys from values
      """, {:ok, %{"section" => %{"you can also use" => "to delimit keys from values"}}} )
  end

  test "allows a continuation line" do
    check_string("""
      [section]
      you can also use : to delimit keys from values
          and add a continuation
      """, {:ok, %{"section" => %{"you can also use" => "to delimit keys from values and add a continuation"}}} )
  end

  test "allows a multi-line continuation" do
    check_string("""
      [section]
      you can also use : to delimit keys 
          from values
          and add a continuation
      """, {:ok, %{"section" => %{"you can also use" => "to delimit keys from values and add a continuation"}}} )
  end

  test "allows empty string thing" do
    check_string("""
      [No Values]
      empty string value here =
      """, {:ok, %{"No Values" => %{"empty string value here" => ""}}} )
  end

  test "allows lone keys" do
    check_string("""
      [No Values]
      key_without_value
      """, {:ok, %{"No Values" => %{"key_without_value" => nil}}} )
  end

  test "parses a config option with an inline comment" do
    check_string("""
      [section]
      # this is an interesting key value pair
      key = value ; With a comment
      """, {:ok, %{"section" => %{"key" => "value"}}} )
  end

  test "parses extended example from python page" do
    check_string("""
      [Simple Values]
      key=value
      spaces in keys=allowed
      spaces in values=allowed as well
      spaces around the delimiter = obviously
      you can also use : to delimit keys from values

      [All Values Are Strings]
      values like this: 1000000
      or this: 3.14159265359
      are they treated as numbers? : no
      integers, floats and booleans are held as: strings
      can use the API to get converted values directly: true

      [Multiline Values]
      chorus: I'm a lumberjack, and I'm okay,
          I sleep all night and I work all day

      [No Values]
      key_without_value
      empty string value here =

      [You can use comments]
      # like this
      ; or this

      # By default only in an empty line.
      # Inline comments can be harmful because they prevent users
      # from using the delimiting characters as parts of values.
      # That being said, this can be customized.

          [Sections Can Be Indented]
              can_values_be_as_well = True
              does_that_mean_anything_special = False
              purpose = formatting for readability
              multiline_values = are
                  handled just fine as
                  long as they are indented
                  deeper than the first line
                  of a value
              # Did I mention we can indent comments, too?
      """, {:ok, %{"All Values Are Strings" => %{"are they treated as numbers?" => "no",
     "can use the API to get converted values directly" => "true",
     "integers, floats and booleans are held as" => "strings",
     "or this" => "3.14159265359", "values like this" => "1000000"},
   "Multiline Values" => %{"chorus" => "I'm a lumberjack, and I'm okay, I sleep all night and I work all day"},
   "No Values" => %{"empty string value here" => "",
     "key_without_value" => nil},
   "Sections Can Be Indented" => %{"can_values_be_as_well" => "True",
     "does_that_mean_anything_special" => "False",
     "multiline_values" => "are handled just fine as long as they are indented deeper than the first line of a value",
     "purpose" => "formatting for readability"},
   "Simple Values" => %{"key" => "value",
     "spaces around the delimiter" => "obviously",
     "spaces in keys" => "allowed", "spaces in values" => "allowed as well",
     "you can also use" => "to delimit keys from values"},
   "You can use comments" => %{}}} )

  end
end