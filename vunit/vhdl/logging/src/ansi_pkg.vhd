-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2014-2022, Lars Asplund lars.anders.asplund@gmail.com

use std.textio.all;

library vunit_lib;
use vunit_lib.string_ptr_pkg.all;


package ansi_pkg is

  -----------------------------------------------------------------------------
  -- Public types
  -----------------------------------------------------------------------------
  type ansi_color_t is (
    -- Default foreground
    no_color,
    -- Standard foregrounds
    black,
    red,
    green,
    yellow,
    blue,
    magenta,
    cyan,
    white,
    -- Non standard foregrounds
    lightblack,
    lightred,
    lightgreen,
    lightyellow,
    lightblue,
    lightmagenta,
    lightcyan,
    lightwhite);

  type ansi_style_t is (
    normal,
    dim,
    bright);

  type ansi_colors_t is record
    fg : ansi_color_t;
    bg : ansi_color_t;
    style : ansi_style_t;
  end record;


  -----------------------------------------------------------------------------
  -- Public constants
  -----------------------------------------------------------------------------
  constant no_colors : ansi_colors_t := (fg => no_color, bg => no_color, style => normal);


  -----------------------------------------------------------------------------
  -- Public subprograms
  -----------------------------------------------------------------------------
  procedure disable_colors;

  procedure enable_colors;

  impure function colorize(msg : string;
                           colors : ansi_colors_t := no_colors) return string;

  impure function colorize(msg : string;
                           fg : ansi_color_t := no_colors.fg;
                           bg : ansi_color_t := no_colors.bg;
                           style : ansi_style_t := no_colors.style) return string;

  impure function strip_color(msg : string) return string;

  impure function length_without_color(msg : string) return natural;


  -----------------------------------------------------------------------------
  -- Deprecated as public, should be private subprograms
  -----------------------------------------------------------------------------
  impure function color_start(fg : ansi_color_t := no_colors.fg;
                              bg : ansi_color_t := no_colors.bg;
                              style : ansi_style_t := no_colors.style) return string;

  impure function color_start(colors : ansi_colors_t := no_colors) return string;

  impure function color_end return string;

end package;


package body ansi_pkg is

  -----------------------------------------------------------------------------
  -- Private types
  -----------------------------------------------------------------------------
  type color_to_code_t is array (ansi_color_t range <>) of integer;
  type style_to_code_t is array (ansi_style_t range <>) of integer;


  -----------------------------------------------------------------------------
  -- Private constants
  -----------------------------------------------------------------------------
  constant colors_enabled : string_ptr_t := new_string_ptr("0");

  constant foreground_color_to_code : color_to_code_t := (
    no_color => 39,
    black => 30,
    red => 31,
    green => 32,
    yellow => 33,
    blue => 34,
    magenta => 35,
    cyan => 36,
    white => 37,
    lightblack => 90,
    lightred => 91,
    lightgreen => 92,
    lightyellow => 93,
    lightblue => 94,
    lightmagenta => 95,
    lightcyan => 96,
    lightwhite => 97);

  constant background_color_to_code : color_to_code_t := (
    no_color => 49,
    black => 40,
    red => 41,
    green => 42,
    yellow => 43,
    blue => 44,
    magenta => 45,
    cyan => 46,
    white => 47,
    lightblack => 100,
    lightred => 101,
    lightgreen => 102,
    lightyellow => 103,
    lightblue => 104,
    lightmagenta => 105,
    lightcyan => 106,
    lightwhite => 107);

  constant style_to_code : style_to_code_t := (
    normal => 22,
    dim => 2,
    bright => 1);

  -----------------------------------------------------------------------------
  -- Private subprograms
  -----------------------------------------------------------------------------
  impure function colors_are_enabled return boolean is
  begin
    return get(colors_enabled, 1) = '1';
  end function;

  impure function color_start(colors : ansi_colors_t := no_colors) return string is
  begin
    return color_start(fg => colors.fg, bg => colors.bg, style => colors.style);
  end function;

  impure function color_start(fg : ansi_color_t := no_colors.fg;
                              bg : ansi_color_t := no_colors.bg;
                              style : ansi_style_t := no_colors.style) return string is
  begin
    if colors_are_enabled then
      return (character'(ESC) & '[' &
              integer'image(style_to_code(style)) & ';' &
              integer'image(foreground_color_to_code(fg)) & ';' &
              integer'image(background_color_to_code(bg)) & 'm');
    else
      return "";
    end if;
  end function;

  impure function color_end return string is
  begin
    if colors_are_enabled then
      return character'(ESC) & "[0m";
    else
      return "";
    end if;
  end function;


  -----------------------------------------------------------------------------
  -- Public subprograms
  -----------------------------------------------------------------------------
  procedure disable_colors is
  begin
    set(colors_enabled, 1, '0');
  end procedure;

  procedure enable_colors is
  begin
    set(colors_enabled, 1, '1');
  end procedure;

  impure function colorize(msg : string;
                           colors : ansi_colors_t := no_colors) return string is
  begin
    if colors = no_colors then
      return msg;
    else
      return color_start(colors.fg, colors.bg, colors.style) & msg & color_end;
    end if;
  end function;

  impure function colorize(msg : string;
                           fg : ansi_color_t := no_colors.fg;
                           bg : ansi_color_t := no_colors.bg;
                           style : ansi_style_t := no_colors.style) return string is
  begin
    return colorize(msg, (fg, bg, style));
  end function;

  impure function length_without_color(msg : string) return natural is
    variable idx : natural := msg'low;
    variable len : natural := 0;
  begin
    while idx <= msg'high loop
      if msg(idx) = character'(ESC) then
        idx := idx + 1;

        while idx <= msg'high and msg(idx) /= 'm' loop
          idx := idx + 1;
        end loop;

        idx := idx + 1;
      else
        idx := idx + 1;
        len := len + 1;
      end if;
    end loop;

    return len;
  end function;

  impure function drop_color(msg : string) return string is
  begin
    for i in msg'low to msg'high loop
      if msg(i) = 'm' then
        return strip_color(msg(i+1 to msg'high));
      end if;
    end loop;

    assert false report "incomplete color escape did not end with 'm'";
    return msg;
  end function;

  impure function strip_color(msg : string) return string is
  begin
    for i in msg'low to msg'high loop
      if msg(i) = character'(ESC) then
        return msg(msg'low to i-1) & drop_color(msg(i+1 to msg'high));
      end if;
    end loop;

    return msg;
  end function;

end package body;
