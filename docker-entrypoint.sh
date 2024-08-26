#!/bin/bash
# If the ENV variable is defined directly in the lufi.conf configuration, there is a PERL error, so it is written in fixed.
# PERL ERROR - Can't use string ("'10000000' => 90, '50000000' => "...) as a HASH ref
if [ ! -z ${DELAY_FOR_SIZE+x} ]
then 
    sed -i -e "s/#delay_for_size  => {/delay_for_size  => {${DELAY_FOR_SIZE}},/g" /usr/lufi/lufi.conf
fi
if [ ! -z ${ABUSE+x} ]
then 
    sed -i -e "s/#abuse => {/abuse  => {${ABUSE}},/g" /usr/lufi/lufi.conf
fi
if [ ! -z ${MAIL+x} ]
then 
    sed -i -e "s/#mail => {/mail => {${MAIL}},/g" /usr/lufi/lufi.conf
fi

touch ./log/production.log

exec "$@" &

tail -f ./log/production.log
