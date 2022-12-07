if [[ "$CURRENT_COLOR" ==  *blue* ]] ;
then
   $(sed -i '1s/color: blue/color: green/' /root/sysctl_param.yml)
else
   $(sed -i '1s/color: green/color: blue/' /root/sysctl_param.yml)
fi