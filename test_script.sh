#!/bin/bash

# Script to generate ANSI colored output for testing

echo "Testing ansi.nvim plugin"
echo "========================"
echo

echo -e "\033[31mThis is red text\033[0m"
echo -e "\033[32mThis is green text\033[0m" 
echo -e "\033[33mThis is yellow text\033[0m"
echo -e "\033[34mThis is blue text\033[0m"
echo -e "\033[35mThis is magenta text\033[0m"
echo -e "\033[36mThis is cyan text\033[0m"
echo

echo -e "\033[1mBold text\033[0m"
echo -e "\033[3mItalic text\033[0m"
echo -e "\033[4mUnderlined text\033[0m"
echo

echo -e "\033[31;1mBold red text\033[0m"
echo -e "\033[32;41mGreen text on red background\033[0m"
echo -e "\033[1;4;33mBold underlined yellow text\033[0m"
echo

echo "Run this script and redirect output to a file:"
echo "./test_script.sh > test_output.log"
echo "Then open test_output.log in Neovim and run :AnsiEnable"