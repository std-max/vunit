-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2014-2021, Lars Asplund lars.anders.asplund@gmail.com

library ieee;
library vunit_lib;
context vunit_lib.com_context;
context vunit_lib.vunit_context;
use ieee.std_logic_1164.all;
use vunit_lib.axi_slave_pkg.all;
use vunit_lib.axi_statistics_pkg.all;
use vunit_lib.checker_pkg.all;
use vunit_lib.logger_pkg.all;
use vunit_lib.memory_pkg.all;
use vunit_lib.queue_pkg.all;
use vunit_lib.sync_pkg.all;
use vunit_lib.vc_pkg.all;

entity tb_axi_slave_t_compliance is
  generic(
    runner_cfg : string);
end entity;

architecture tb of tb_axi_slave_t_compliance is
begin
  test_runner : process
    constant memory : memory_t := new_memory;

    -- DO NOT modify this line and the lines below.
  begin
    test_runner_setup(runner, runner_cfg);
    test_runner_cleanup(runner);
  end process test_runner;
end architecture;
