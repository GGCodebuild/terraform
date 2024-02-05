###
# File: main.tf
# File Created: Friday, 7th May 2021 1:02:57 pm
# -----
# Last Modified: Tuesday May 11th 2021 11:51:52 am
# Modified By: Gabriel Vidaurre <gabriel.vidaurrerodriguez@windriver.com>
# -----
# Copyright (c) 2021 Wind River Systems, Inc.
# 
# The right to copy, distribute, modify, or otherwise make use of this software may be licensed
# only pursuant to the terms of an applicable Wind River license agreement.
# -----
###

resource "aws_cloudwatch_log_group" "mcp_resume_subcloud_cloudwatch_group" {
  name_prefix = "/aws/lambda/mcp_resume_subcloud"
}

resource "aws_cloudwatch_log_group" "mcp_suspend_subcloud_cloudwatch_group" {
  name_prefix = "/aws/lambda/mcp_suspend_subcloud"
}
