-- This package contains useful operation for manipulate path names
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2014-2022, Lars Asplund lars.anders.asplund@gmail.com

use work.string_ops.all;
use std.textio.all;

package path is
  pure function "/" (lp, rp : string) return string;

  pure function join (p1, p2, p3, p4, p5, p6, p7, p8, p9, p10 : string := "") return string;
end package;

package body path is
  pure function "/" (lp, rp : string) return string is
  begin
    if lp'length = 0 and rp /= "/" then
      return rstrip(rp, "/\");
    elsif rp'length = 0 and lp /= "/" then
      return rstrip(lp, "/\");
    else
      if rp(rp'left) = '/' then
        return rp;
      else
        return rstrip(lp, "/\") & "/" & rstrip(rp, "/\");
      end if;
    end if;
  end function;

  pure function join (p1, p2, p3, p4, p5, p6, p7, p8, p9, p10 : string := "") return string is
  begin
    return p1 / p2 / p3 / p4 / p5 / p6 / p7 / p8 / p9 / p10;
  end function;
end package body;
