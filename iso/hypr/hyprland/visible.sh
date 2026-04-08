IS_VISIBLE=$(copyq eval 'visible()')
if [ "$IS_VISIBLE" = 'true' ]; then
    copyq hide
else
    copyq show
fi
