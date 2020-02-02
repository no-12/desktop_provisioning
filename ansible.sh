#!/usr/bin/env bash
ansible-playbook -i $(hostname), playbook.yml -v --ask-become-pass
