if  [ -n "$1" ] && [ -n "$2" ] 
then
    cp configIPrange.yaml.tmp configIPrange.yaml
    echo "      - $1-$2" >> configIPrange.yaml
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.0/manifests/namespace.yaml
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.0/manifests/metallb.yaml
    kubectl apply -f configIPrange.yaml
else
    echo "Please enter IPRange for metalLB"
    echo "Example: sh installMetallb.sh 192.168.0.1 192.168.0.10"
fi
