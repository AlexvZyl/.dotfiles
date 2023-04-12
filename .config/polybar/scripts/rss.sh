#!/bin/bash

newsboat -x print-unread | grep -o '[0-9]*'
