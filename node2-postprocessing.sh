#!/bin/sh


ssh vagrant@master '/vagrant/deploy-rook.sh'
ssh vagrant@master '/vagrant/deploy-datahub-vora.sh'
ssh vagrant@hadoop '/vagrant/deploy-spark-integration.sh'

exit
