# Setup for running myriplane on new incus VM

## Create instance

```bash
export INCUS_NAME=pete-myriplane

./create_machine.sh --os ubuntu/22.04 --name $INCUS_NAME --target H93 --vm
```

## Install everything you need

```bash
incus exec $INCUS_NAME -- sudo -u ubuntu -- tmux
./setup_1.sh
exit
```

## Build myriplane bits

```bash
incus exec $INCUS_NAME -- sudo -u ubuntu -- tmux
./setup_2.sh
```

In One Terminal

```bash
cd $HOME/myriplane
./run-etcd-dev-ssl-peer-dex.sh
```

In Another Terminal:

```bash
cd $HOME/myriplane
./myriplane -v --verbose2 -d -c my-config.yaml run 
```

In yet another terminal

```bash
cd $HOME/myriplane
./myrictl init --api-url https://loginmyriplane.local
./myrictl login admin
```


