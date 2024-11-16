#!/bin/bash

cd "$HOME"/myriplane || exit

make local setcap
./myriplane -d -v init -c my-config.yaml


sed -i 's/#tls_cert: "path\/to\/tls-cert.pem"/tls_cert: "{{this}}\/loginmyriplane+1.pem"/' my-config.yaml
sed -i 's/#tls_key: "path\/to\/tls-key.pem"/tls_key: "{{this}}\/loginmyriplane+1-key.pem"/' my-config.yaml


