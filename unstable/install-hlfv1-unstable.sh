ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� A�Y �=�r�Hv��d3A�IJ��&��;ckl� 	�����*Z"%^$Y���&�$!�hR��[�����7�y�w���^ċdI�̘�A"�O�έ�U���Pp��-���0�c��~[t? ��$�?��)D$!�H���$	�)cA|�{j!8�M �&�j�|�e���E��ac<?�8�]MA�6���M>�o�5��F��S�Pk�)k�;�ԑ�@fh�|��j���  �m	[�6��!����h#�"�
��L�Cꠘ����� ��Ox���o������6��
mHPfc0,oJ��r>�C�V$3A��C�LYmk��2L��t`��Ȧ�գJ&����ؘ�0��t�!���0����E}?��`6m�����Lڡ�뚎O��M[S�Ú�)���"K1���.�;�0�e�AW
�(ؤ��ZW\��B�c�Wll2�P���ơ���d�T��ԭ��jm���AX��M��單���i9�N��0;�v(�Q���舎`;.D���Na0�)�Bqي�>��aтZm��O�:fC,T�*�Ŗ�x�o�v��_�AL�N�_Z&"C��Q��͑F���i}M��A�}T�[fJ]�9�E���D]��7��d޹�B�m`8�~o0�8�d���bvEEu���@62�mɤ����r��
>p5p@E� 5��OC��u����<�����I�'���<�{�������o#�F���נռkl����_���G#R8,J���K����_<�.TӌPZM�� �?}��S5�jL��*)Wv?T�ʩ�[����<��{���S胎!q6�|����3��>]��*�bx-������0C�;Pi�
�[ظ�6���4��O�)�������n:��uf`ȱ1^
��[:}4��2A��Y�ƀά�ـ:6�^��tܡ�b���l�qL�3���Zڴk�� Vd"�\����O���f{�� �lhɓ�S�����3Jc�
����)�c7�9}��j���5k[&R�D��wE�ȎT���������Xi)M����:���{o�;� �aEc�W~�ٷF�Ps4]@Sij]��7���ˁ���!Z@�{4Z���� ����H0�'��@�Rs�A�?�s����$���Av5�k���`��O��4{;tWp��&O'�Xi��W���P/����	m��t@C&j�."���ahFc�R���J��;�7�+�;w�>W��79��Ro�P$�w;����W��ATR��{�=J�f����}�G"���X?e����Ó�����s[/�A��I�f0� P���,f�	���ޒY Z��	�\6g��N{�?L����uX�=�K K�1�+�cc���s�����,�Nydh7y��`o�����ل�ͯ���>�9��v�>�X�:�G.Bȕ�f�h�UL>��&�(�;�Dv�CA�H�A��)M��g~<�~�v�3��6و�f��7�<m���<B}h]6��۟�����F�6����G��l2qz@�D����q�eѝ�W�+��<t��^9��©�@k����O���~(���'�k��
X��|�0C�GkyOm,�Q
ǧ�_\���\?)=:�q�3�l���OO�v��;fb�稷�3a�u�Ӥ�� �6�\:_��u�Uw��T9X����&�U��=Ϯ���=�C<�]b�r��x�Y9YΧ>gʕ�A���`�6{N��,��_'�rڴ7l��_��50Yaǋ*�n��4	E�x�t��,ݩ\�o�*����B��:��h��.F�s��R��kC���#F�1P��D;���V$޿xʢ�H�o߂�3��3xj"��=�$̹���mP$�8�Ӯ!�?~~��R ҺtN�tzB'�i%LF�o��<����i� (�$�_�����s��p'�E���������X�_6���AӾ��2���´�����
���|����贁f��utLT�.�Ў�~=˾�:w��?�/ݽ�e������}��X��l�s'.����7���_	�t�����G�G��?����J`��o��±A��ed��|	:�f���v���<����#���ba'��c"N.�vw~v���^|J��c"B��tl���Ѿ�`�'V߲Q� #�{֐�D�Y��ҿޫ��X�O��˱�gҙ!�.�����Աu$e#����<~�̿UG\!�	���ŞBݘ	�0��.R����ke�0�:x�3��{g�wJ����i0p(:�����-�M��]����4}��P�o����A�|�Zs�Z���BDl�pu)d�3�R��W��a8�=�q<����@@
Aq�o�� �{�
���[�����&�,^����]���T�M�8Y��J�����d��m�ѴA����~�Ox=4���v�n*�wy)�4�76-�R<���]	�U���?w�����B��)���l H3���瀌��e ��-�]�̣�)�
�"��V�a���� �����i}�P!����,��6z�.zqSwiƳ��LQr�^���l?�Ė�&�AxIC���):&�H�K0��gi&/�ČS��ffΘh}:YƬ��raLu*��ӫ݃Bf�0����)�r����#��s���%3��Ґ�@Z�"��H�?+�wc���1��G�������>��۟��\ ���U�����\��/��Ax��_!�>��F�u��J�������o����������5�S�營P�&(�Nl�Q���꒲�H��DX
�!�D$ŤD-�(%���X�oEõ�ht�?����57MxC��W���NG׈�B�n�y�x��S�Ka�¦�9���'nch�F����W�j�ȿ��W#:<���庳6�e����7���d��'��7'&ټ���6����qʈF��xC���7���^yn/��ýU���a��W���~�ɛ��D�����"k��
���X�	D�VCSI���f!�7I_�N�t?����Ԧ����oizΖg�OPDQ��&�x�V��VDتo%P]�j[JB
G�ؖ
%"	
��0Q�&�$E�	ͧv�+���:�t8
�L._�L����Sr5�J��|>�;O�d%Ր{���ȗ�s`_��P2��o�δ�R/�8����幐!�=�2�O(ȭ�,e��B���p�����F񘐪�Z�f-��k��<�\d��#��RM�gZ2��P�Y�4�_���.rU������\�v�q��4��7I�=����ݴ]�B5.6��환�ݦR,T�^�<.T��A5>�e�L��3NΓ�B��J���R)��>>��Td���R��^)����YWiG;���I!YrG~Q(�3��Y'�9럞D���y�2S/$�!�z'���O�2��P��(���܅��.vk����d!���U
RBndr�����ٕ����9[{ɒ�k]T��c�ߍ�h�{'�Q;�&�pR��N�����^>���=y/Պ�E��Y���*V�y���cgR��k��Ϋ��~A��Z�ު�^&���6�r���n����[�\�)��J��J�BjO�'��t��|2��0����^�c�M$ L!������.�r� cddS�А��T�����R응�4>֪�Hڂ���I"�4�^���(�'G��D7���F%����뾊�8Ӂ�|���;�wƛ���!�~JJĻj�,�3�g��b��`(�i�}�h=������O�D77���b����g�����^�����>���Uwhj��=�5�h����#��"�]�������r����9e���B>�Kl���F'sBR�TjB������Z(��j���ف|,T�7��;����M#岼W2�N��\)Y.�ݔU:*�;���e��/.��vJ�/j�񘓎[G�R9ڏfu=:��F�yba�T�(9�>r���ݪ��(Yh�B�1�[���ܳ�ˁ_����������>��wj�{�kx�˰��Y���s%0n�����Ը�϶z���w���K�QHZ.)�RC��x��d�G��}]�8i8!KD�x؎<��A�,[he����8��r�����;���~��6�!��}K�]�ݎѨ�aZn����}�Y���'��ccXR��>����-�����勤���xR��7Y\d>Y ��NȺʴ�e��BrOh��a�M`�M{p�r�2��(�-�#���B�?p#�̆Ń H��fh,b
�iT4�Kv m�64`�f?񢖀�Uv��>�4���2�K���x �Pd?�3j�4nC��c�U���ۦ�J)l+�ځ�"�!�XU5:�K0�@�a]��.�l��<޹F���\L#����=y(�m�ʼ���s���}���A�li��d���L�Ȁ5ݽ:�.h��f��c!�H�YA;�G�5Ԏ��*@�� �����=h�\J�T�>h���4�<:l�� 4 4Mا�B�/�ԐEhg���iۖF�DP��T�'oO�$��e�����bT�L��6(��Xа�|�tуctRdΰ�����2����B�[���G��3���cj*���'8	�n�HƗ�]쥻:�$��[��Up8�� H���<��x�ik�Zi��m�`��m�:f�4�$5�!�͗�DV�2Z���������^�:ƤLk����OJ����C_q��S��86A.��7���T�-��,����]�AsN���)��>�~!���EO*��F��S%��$_�!��f��z�#��2�.%:�-�Wk!7P��Tޭ%Pœa�!۝b���H.i/�Lq�������K�j7�W�2_*� �+���G��/�]}�*UM��(�K�����o'D���d���];t�!��T�����Tݱ�]1�`j�nz�<��f����F�DJ���54�M4:!Z�d�nO���+X�5�#�qNuB�wٶ݌}�t�i�Q�`$2D��d>�����4���/>�8Y,��C���:��Զ�(��>kU�I��x,��zĆ;�@K6џ��@��V�����6��E)"L�����k�uK��=Msq7=Ej�A����F}��#��\���c'qn���dq��N��y�؉�,P�@H3�H�b7#�!1�0,����b�!v�|�q�]�[�sZ}�^����:���� �߽$��`(�%��?���o�s�/�=�+�o~���b�o������/~����%��8�9�|G�o����Go�b������	U���0��dE¤pH�P�Z�P8ҔCxL�H
k��n�R!�2Nd[��9d�B�������������?�������tn� ��Ɓ�Ð�b�����>��
E�����w�����{��� ���G����P���a�ˇ�z����o��[��v���+ ��2p�b6��u��򱡥c)��{e�a�S��9��{�|���=f	�U�m�U.�
�Ӳw��nT������b����0�yvIB�>zR�5$���~V�!BJ�Ǘt�F��EZ��BQ09{h<g��zu>nb��@�
ź���g�5�p�8Lw���EdgB�o&L�ᔛ3��[�̠�Wq��,O�D������<,�ͳ�z�ܝ��H�@�T�a���~�/O�f gλhչi��y}���K#����X�5Š�t�ZL��Hw�Hdg%�ܜ)�b��2�])��ɂn�<]H�m�}'9�(D�����za��dM�Y�3�M@ϖ�B�
a��:I���#:�I7�s�|�4Ҥ���Y���������ÛE�hUY��N|1�Z�g0u��2�E5ry�f���3�u��֗��i'�'kZ�LRҬZ*E:9�ҳq�ss�?9�Ǌ�!����%tu6��.���Jn���+��+��+��+��+��+��+��+��+��+�����1�w�7K)��~�T��d��α�v�YMċ1��ĩl��i��p��v�{Q;+
�U99_"@��E� ࡐ��Z� @��N�D͔� t7o`������Z���S�!VLF��М!2�<2�H�*�[��6K�X5E��L�PK��9��U�
'�R�Q459��Mpb46GR�,PW���?7Q?�ƈn��X��X��Ζ��k�TN�{KoEd�2C�¹y���ЩY8�Ñ)��Q
>����L�5�z�Sd�HGq���Z&B�X-��
�̝VT��(�&�<"cmVj����`��%\�]�B��_�����G����8z������c�y����p�]��wC�3佸}.6���0?���"�I�����ܾ?� u���ԩ���w pd�����׼\T,�G���G��}��o ��\��|����O��0�����_)�2KK���J��Ft�u��3�E��k��nm�|I|�:?��%W�ǉM�o�	[���I������,X�ӕ\�m�f��Bl�U0��#�LcS���J��~&JU�E��r�Ϭ��0&�cB�QJ�%�HE�T�J�㼒���Wg�rl�gs�o�S�� �7��n��ユ���IӘ7´mW��A"�Q�q�2£&R�-e�P�C�,�]��Y�i2�:~�Y:���4�
qH2�)�L����r�24�Q�r;y�G"���[h�`�Ҩ[��zI�"k���M�,��*�֔E?_K6q�[*8&*�H�_�YD#�hA��f������icL/�m�2C�֔��l���tm�VB'>��_f<��+�&�g(�i��˃�0�d�h&�w���rK��_��/���̦��X��@fٮ����p�������Ȳ�EVY�x��=3+=.�;r[~w��6~��;ݳ�D�Yզ���T8��B.ӡeO6t�������3y����i��`�aI�f��~U-��Ju��a�)f�a�nm��|�F�x��6�4U��g���P�
-Цm(s��h�<�����&?�;��\ G�B>�w������Ǒj�����	�B0�s�҉'��.Y|���i��+�FEI��}�,��t)2K#L�͛�!p�y�(Z�a�p4�J����s��.L�+źx?��!��(�^���&��+y"+E�X)!;�Ú�
x���])$lY%f�ݯ"�I�Q$�k?j�m�`��	�	r�#W� +;�Re"Y�1W��9�*Ŀ�Z����P�\i����:����'O�ꀋM�$�sq�nW��Q(��[�c\��X��EI���YJ+�G�n2�-�ә�D��	�(�U(��Qv(�H9S�C�L�|�4%/�C��I��T�<�)ļ�N��R���
Ct3j)���p�,4�S��+U�!ҵZl��g$����J���Q˨Ę�y�J��)0��(,���am!6�j��c�w3yvihe��j�[���g��x�o�y��n�~���d�v!��%�c�ݘ��W������/#?Ns��>���X	<���������1�3�d��%u���}�<x��9����A/Ϸ�w`�v�x7�&�����)�u|èH�*�>$����$��J����ȃ�������Yu��G���	��p�dHN���9���;�_+}���#�šey�躢��#�C����=z]���Y9B^��;���[|�x"c~=�/LW|�èЖ��p?|��Gz9�_��>z�	�:�G���Y��V���5����N� ��T�|9ص2����#�A�ɰ*I���4P�.v�����Q o��f_����'0���ϑ�I�3��U?��vW@��wN��:oXU��e��ѥ�e�p?]��xo}�Y׋llݮ��V �W��bNvt�dG�^6��S�{{��:����dC�N���Ѹ�G�ڀ"��=,iA�1
@>ڈA�)��Yt?Q`��� �3����PїA������a���&����� �1^0�s�$䍠�M598T,��]N}*�~yj�Wsj�2 ��,>_�� �jd�0�!�l�x�xK|t���]�C�8s"�������W��Zom���A��h��p�NFC�Wf�:竍g���`�`}?iE�<�Uae�Wa�ɪ�
E��c,]gh�cm�kd�v���N�k��Б��1�>k�c�,�ۀ��ɸ�Ћ�'�� �a~�[�X�N�őU��	WDV���_�����	?3 WL�Xٜ�M�����u�y�����h�lH؏���V��u���ůK~������&x�d2�u��c�������Б��� �N�
��`iA�덺\��Yp���7��O�x0�27�j��'p��yC��G I	|�<���E>�]]�R�88sx�n�%��}<�%��h+[�0(i�+YE��֕��r��m)y��S���p���t;��
�Rɽ}Q�.�z&��}�*i��s�����/���;u��[ Y춽-���/�x�݅�A���4 (O(t�Ǡ����푋�*T
6AYX��,�$H�뵃�`g�����z`u���A΀$ xU9�cM�H�`��cf�\L���+��5����
7i��悐1ktӚ穥�A��°&ٞ+��v�M�x��6��/��W&��YÒW]\u��J�9MX-;ǢA���.�/p�e�{c���_�v[���6,�i�q�U_�V�N��n��4���*Y�]l5�`WB�D�ԙ�S�''���ɨԃ�aM�!]�<���8� ��YW����lN�N :��O`����X�Mܶ6�4ND�b p�I�+I῜�FnG����- 	l�);JC:@��[�������c3�M���X��_�p�P>=�U ��~ԁ��x׎�e-���\�}�����o;�͕m\q�����?�P;���#���	�	� P[�U�#�-+a0��kD�}��=����Y�>�1����BwV��䎂%�X��,mU����G���|���v���?g���+:��7kG"Yj�H�IHR���E"CJ�lST��Rڸi�D4C��1Bn���%��QE"(�L�ۂ�=���� f>sb�XVi7���d�?��|b=y
�
c�\{;ě0�ξ��Y�xLjR��l6�p�Ȓ�J��I1I�(*S"X��*!�)�RȚ�hL	G\�$Ś���������'�'p6f��6P|����޹%�'���Nx�3���.*�2���,�#��+���l�+�\Ѣ�$��t�,�Kf�
�y&+�i��l|I�4��R��+�����_81�c����+��f/����k�*Ng�R�g���Ǯ�"]mua��ݳ.x�� ��ڑ���t��3�j�>i���N�����j�i];l�}�¶I{�L��Z�v�c;7L���l��9CV�Hv��%�)��V���=�+r�ȓ|6y��������g�9v���	�c�����˲���M���EQp��It2:��S�O��$h�̢�KO��y]n�`6���f��\��*�ʕ�x.���gYN�抧�5�g.��/��7��:���v&�]{�S�<:�1�j86i�-����?YZ���=����,sI�x�O��3&�/w�܈�d,~���m��(x�ę=xg�Y[�t���	��A�.bj��N�i��|��f��Ķ��7����B?&��
|k���2���Շ��Gm�;�$�0r�c��v�].nv��ݱ��VD�C��Y������
���^�l�x7�o׋6y7��&��!��>���Gw�q��Y�;qX�}���[2�6�""�a���^	��$���;���Gz��ohzK�M��C�C����B�S����Kz�?�c�򟌄�i_������}O�W6�K�_��'7�������t�@s�@s�@�B=��7K�(���#�����Kڗ���1���,��#Q�dG��f;D�Yj�"Q��PQ,��Bd$Ԍ��J�<LH�3�eQ�W;�
���o���_{I>�o3L�����:4��H+���9r\��hJh8�A��P��+�ye�In�O%�
�9�.rM}is����C
�1��-.��hY����Tč����[��餔��&�Jq��R�J�)�����1��������_~z�������˗�66��yH��>��6��8u8��Gz�?��8���>Ҿ������W>��A�߿��:�##����G�g����=_�t������l������W@�ë� t8%�:�����w�OR��:��}�WK�C?��P��K�����?��%������>�!T�!T���we݉�]��_�޻V�<\�k}L*"(ܼ�I�	���Ī�hwR�
Е��RV*)E7��s�~����O��{0�	�����w���P�m�W����?��KB���C+@�
����!���U���?\����^βvc��r���v.���������?���'�3������}x����|l�3���'�J�|����m�Y8FO�].��R�ݳ�z�y���d����v�f*V���bK�*[�{����a����y�j�G��ǰ=���7Rs������'�#{�mw��2�u�|����]#N���	Ie��{��r6O����}��ݢ��{a�ʑ�GN���Fܳ�]#JI1|iZ��C$*��ʷ)�=�M{?���?�m�O��NU�Вc����l�n�A-���+C��ӂ(X � �����j�������H�*����?�p�w)��'���'������p�e��/�#��
P�m�W�~o���)��2P+��MP�"�P���uxs�ߺ������:��1����������X�q�������s]�R���xt�Ŀ/둷���A�N��<�����l(��h���p���R-�B{D�V���׌��ɞ"(Q��'��mgL���T�y)��͐�uMΞ�z�u}�k|�T���;����\�/�ȕ��K������7/?ph(s^%c�S��Jp�u\t�4�	�$�L�Km����f[Aۨ��|�:t~8sMRF�劉7j(9�����%#m�֧�a���Z�?���@����ex���.��@����_��x�^x����)��3c��>Jc�R�R(�q^����z�ﳾOЄK3>Nx>J��O�!
g�8��������/�2�?+z��8�B2h��:�dI�wwJ�<� �yg��&��k�/�����H�GO�F��ɪ}�&�md:�9���40��&��7��e;F��H�%����9L/mFT��6Ó���/�p�����P�����o������P�����P���\���_�/�:�?���W�ݐ��*7��q�D&rp�3�O9�^�v��Y8�§�0K��O�t_�Ѡ3�~��.��ݶK�92���œC��F�����*:�C�2���306dUɦ�9��E=��8�������������u������ �_���_����j�ЀU���a�����+o�?��迈���?��}[���0���ɱ|�����J��>����6�����Ϝ�<=�g  ֳ� �HU�=Z���RE�� �y og	9�U����B-��D��n����vs���,LS�����>�u��A�����I;�s�E����7�E��99�}7�^��5������3 �%�p�vB$����D��;��.�iF� ��Ǒ y,V�w�P(�H���>�f?�I[�41z�@0��&4��FX9%|�q&��pҀ�k�!*�HE��!m5���-|�1��!��3I�m���m�#2����k�fҷ�"A��:�:�x���l�k��K��ng|���0��#A���Ͽ��.Lx�e\�������P0�Q���8���������L�ڢ,�������_��?����������?a��_J��z4�z���,�n��!�.�.M�\Ƞ,͆���� \��I&�\�a���P�����/
��R�+���wXJjS��ܱp��=|4�œ���\ߎȂ�521��e��J�$����4r�%����m�=6�!�YB?���n�Gqyn����Fy�\	�<����f�8��D�tZ֮�����u��c����)���׈���%��P�����O��e��O���0�W��7Xǐ�^G ��W������t��_���k����G��	��2�f��������C3��)��Ʉ�y�2������o�wo��2�ϑ����>�����������w����p�)�q�Zp�7g��V=	�^�LK%�#�O�:^P{Z�#��:��r<bVC{6uU^m��ǔ�8�������i�`H;�|nG���,���d��r�����D�;ƹ���q�������ަk3���ߡb��b�KuH�=�OeG�&ۢb�d�4"��ֳ�!ɺG���|�4I�Bs3��w�f�D&���Z��ȩ++��1�����E�Hr�1��!_���P�wQ{p�oE(G����u��_[�Ձ�q���׊P.�� x�P�����7M@�_)��o����o����?����U@-����u���W�����Kp�Z���	��2 ��������[m����7
��|����]h���e\����$��������}�O ��������?���?����W����!*�?����=�� �_
j��Q!����+����/0�Q
���Q6���� !��@��?@�ÿz��P�����0�Qj��`3�B@����_-����� �/	5�X� u���?���P
 �� ������"�������j��������(����?���P
 �� ������?�,5�Y��U���k�Z���{��翗�Z�?����:��0�_`���a��_]��j�����Wj����9�'���
 ����u���{�(u���Aڛ�>�(;c�p��s$N�����E}�D}c��0�u9�$)��g��_ԁ�	���"����ѥ��*Oo��s�8��@�6��Wo�0"U�^OP����K�F�>?BMl���ju\���/�����!��<?��̰�a��ˢ�L��kq�4�0B���>C�L�V!e�:x;���xc'����!��|S��Ա�p
�<����ݓ����p�����P�����o������P�����P���\���_�/�:�?���W��ШSc߷�Vc��Ⱦћ�bg1�a��/[��?�q_�?+\�̓�ҋ&�oX�n7W�xu���d�"�!u�(<a���m�Ӄ���b>MOm~;�jҠO�i3�QBU�v��eJ��ｨ�����w�KB�������_��0��_���`���`�����?��@-����������xK����������MF�8w�Ɯ���
�Q������j������N�ic��|���d�i��-S�o6���Ҥٙ�^�v0	$o;��N�CS=b�^4��aF�U�z�Ş�ΈL��q/�S� �}��3���Ƚ�G/��5���҉���n	�&\�;!�[���/xysY���|�E�PoG��X��uC�XG
�"��O��L'm5�_�yM6D�Ü<{�I���c�d�1({�y!�S����Ák�{KG�cAN�p=7Q� Z������$J;��Ĳ9ۤ�5����
�$�'� ܽ���?��E����3�������?��/u��0�A�'������?%���WmQ���q�'Q��/u�����$�(���s=!ӣ~(���1��y���(N��W���tK���=�Cӏk#�Lb�a���.��u�rO���-�7o�"��Y���g�M���[�t�|����?Y~�G���Y~�w�������_[��&D7�rx�.���5��sl���-!�_�VE��j��_���0쑯�i#�W�@F���en'��e*�?���1L%��a����9s�7)a��tze��h�&V{8�[�w	����?�h�'+��}s��v��rYs!��ׯy��l?�雭�CF���O�@��X��M�-������f�܈��fǠ�?��Y��ֱ^�̑��%A�c��b����R�w:`T0��O&�i���©K�F�DBl7]!7OS�஽\���(PGnJ��l9�?�̾��˿��wC-�u7��ߒP��c<
�h�p=f�b$�r3�����$�s3��Q���|�$��K0�S>z憨����Y�C�?��0�W
~���DG3���� �V��N������]��ɣ�2�#�/���r��j��\����/>��5?���0��2P��1Ľ��������(��������4�R���+������S��oe�0�g]f�:��w��k����y�e�NΩ'��j�!��������������o�	�����|��퇼��3�xov��Z�@�t�!����0���pkL�Qśv�8�:�i^\{����|rH>cg�b�nu�XI����|����~�����b|3�y{�n�����v���t��-3��ye�,xy����$</���Ys{�a�Nr9�_J�������v�#��j^���!Ͱ�\؄sr6��7V]��+��l��
3_����u������-%��)��I?�YC���׎�O_���0�y�b.���o��.X��]�.�`,G����(�����G<}�A�}>~�����봍�Z�r;����8y��Ɖf;T����'Z�;������Z�����ދ���_~?��1
�_������{����+e|����/��XK ��W����UJ���h�e��?�л�����/o��k�����Gc�m*��6�C�'��~��������?ؚ���z��}l��v���[�H '�%�4=���K˳�J.�)ϏI��G�w�\!m]�:W��ѕ~������o�ܟ�Ķ=�;7'u���t󐇞:�U��`�~{�V  > E����B۝t�3�̤�L\�������k������J�w]�u%���uNj�G�3�u����;z*��]k4�t]�o���j�t��9>�V{f4�{�Y�b9m�U:�[r�劘��?ݶZ�jx���)4����c�������q��Y�R7V<�oMֳ�F�k���^[�?^l��4���Vْ�6/Ju�����Bhj��1)uLy62��x5������*&-%�h�Y�Z?�z��ʀ)�u�ZIuG��e��8���j��I�.����\��O������7��dB�����W���m�/��?�#K��@�����2��/B�w&@�'�B�'���?�o��?��@.�����<�?���#c��Bp9#��E��D�a�?�����oP�꿃����y�/�W	�Y|����3$��ِ��/�C�ό�F�/���G�	�������J�/��f*�O�Q_; ���^�i�"�����u!����\��+�P��Y������J����CB��l��P��?�.����+㿐��	(�?H
A���m��B��� �##�����\������� ������0��_��ԅ@���m��B�a�9����\�������L��P��?@����W�?��O&���Bǆ�Ā���_.���R��2!����ȅ���Ȁ�������%����"P�+�F^`�����o��˃����Ȉ\���e�z����Qfh���V�6���V�Ě&_2)�����Z��eL�L�E��؏�[ݺ?=y��"w��C�6���;=e��Ex�:}���`W��ؔ��V�7�r�,IO��j]��XK��]��N�;u�dE?�)�Z�ƶ�͗�
�dG{�ݔ=!��4]�ݢ�:肸�Bbfk�6C�VXK2�*C�	���b���q�cתG��<s�����]����h�+���g��P7x��C��?с����0��������<�?������?�>qQ�����?��5�I˻Z�C���Hb1�(�e��q˶�Ӷ���rgO���_�:Z���`�э����fCM�"vX"�h�.�j��oՋ�mXù��5vy���|�TǮ6�Wr`R��
=	��ג���㿈@��ڽ����"�_�������/����/����؀Ʌ��r�_���f��G�����k��(����i=�0r�������M����+bM�ɔ��į�@q��`�r�M Alz�q�%I�ݟE�ݢ��ƚ>��uwR�K"}&V<.l����ة����$�M�Aj=z�\ks��u�]�6A��6�zE�6�l����ӯ��ya�h������d�]��]��OE�;���{Ex��$%N�� ;��YU+�c���{i�a/l>%��j�S(�tj9�����lԚ{�Lkl�,��fS�
��A����*aJ�t,�a�u�]��,�=btywุmȤ֮4����m������X��������v�`��������?�J�Y���,ȅ��W�x��,�L��^���}z@�A�Q�?M^��,ς�gR�O��P7�����\��+�?0��	����"�����G��̕���̈́<�?T�̞���{�?����=P��?B���%�ue��L@n��
�H�����\�?������?,���\���e�/������S���}��P�Ҿ=�#���*ߛps˸�����q�������ib��rW���a&�#M��^��;i������s��������nщ���x�ju~�I�Z�����be�Ì��yyC��Rѧ���!;3��08A���rf����i�������(M���h��s�/v%�Wӫ��#
��CK.H��G��m�>+�Z�[�e�:	�zޯ�L��3�uj�n6#���YMڒ��IV'��f5�������>v+E,D�\0k�0ۻce�2��4�}"8*�bu;���`�������n�[��۶�r��0���<���KȔ\��W�Q0��	P��A�/�����g`����ϋ��n����۶�r��,	������=` �Ʌ�������_����/�?�۱ר/"a�ri���As2����k����c�~�h�MomlF��4�����~��Pڇ�Zy�����E��T4��xOUg=��o*ڴEo�:_�!�)��+Q��>{�fq� h�v������Ʋ��#�s �4	��� `i��� �b!�	�=n��r���"�+�r�0e�U����taQ�{��'�zWRD6,oZr��#�rXa�)��A,�6u�+�ք�b}���n�&�ue����	���O���n����۶���E�J��"��G��2�Z��,N3�rI3�ER�-��9F�Xڢi�T6YʰH�'-�5L���r����1|���g&�m�O��φ��瀟�}�qK��t��'l$���Ҩ��'�^[�V5s���GoB��]0�@����OD��W�5&�X%^�vQ�Z��\�N%�.,OÎ9�z����,�T-+��>v�e7�����%�?��D��?]
u�8y����CG.����\��L�@�Mq��A���CǏ����n=^,kzGVEbNbb�h��r����֢�S�c'�n��?�/��p��}߯0���ˬ	)�c�c�:b'dq��uz@̏-��+>�jFmY7��zDg��q�Ckrp��ג���"������ y�oh� 0Br��_Ȁ�/����/������P�����<�,[�߲�Ʃ�gK������scw߱�@.��pK�!�y��)�G�, {^�e@ae�;m]墭�u���Պ�V���i��Z��Q�E%�S[Ec9+�ё���`���j�<�N���0�P��TiVhm��z)��ӗf��y�&��'>^�҈���օ8e�;��qS�:_ ��0`R��?a~�$��PWKUE҉ٶ�bN��w��1���(%g�)��Y�&��p�/�R��m��^ľ*(�T$�Օ��Ժ��eC�G��]�KN���qmώ-k`y�b��#��`��a�������Bo�gvw>�2=�8-�9����ő����>:�������Lb�}��4�������6]<�gZd�wO����/;����I��{A����H����#��w��_tHw���M\z�s�gSAN>&tB���E�.מ���?�_w�y���n��#J�u����LN�鏃�˃�?&w,��Z��ϛ�����y��>%Q�q�}��������q_��4����������q	]�7�zp"�sq�	�7�������F��^�O�Fs��=�~g��T��4���c䤯v��	=���?;W�$r��Ozd9�t<Z���39��	�����U�އw���s<��lx|����B������������;�����;����UrT��-�$��ݧ�;���|��H* �m��u�?��>���:y[�����|�n�^}�%�jy^?�f�6����	�<���Jvs\CK�Y��x�_�s]ǵ�u"o�������;�R���7�8P���p���k-H?��mt3��4���k����k��skrvg�=�O�y���L�M3 ���^:��~�7·���+���I�L�kaN��0#�X|n<�g�&��ɪ����)%-��"���Ɠڽ��N�����w�v��ȏ���I�	�0��څ_R�ûW5�2=�;��K����������>
                           ���ɕ�� � 