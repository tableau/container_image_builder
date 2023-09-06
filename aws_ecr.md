### Installing database drivers in a base image

```
# build image
git clone https://github.com/tableau/container_image_builder.git
pushd container_image_builder
cat <<EOF > variables.sh
DRIVERS=$DRIVERS
OS_TYPE=$OS_TYPE
SOURCE_REPO=$SOURCE_REPO
IMAGE_TAG=$IMAGE_TAG
TARGET_REPO=$TARGET_REPO
USER=root
EOF
# if needed, copy override files
# cp /my-path/download/user/drivers/$OS_TYPE.sh ./download/user/drivers/$OS_TYPE.sh
# cp /my-path/build/user/drivers/$OS_TYPE.sh ./build/user/drivers/$OS_TYPE.sh
./download.sh
./build.sh
popd
# push image
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ECR_HOSTNAME"
docker tag "$TARGET_REPO:$IMAGE_TAG" "$ECR_HOSTNAME/$TARGET_REPO:$IMAGE_TAG"
docker push "$ECR_HOSTNAME/$TARGET_REPO:$IMAGE_TAG"
```