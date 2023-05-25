#!/bin/bash

# delete policy if exist
aws iam detach-user-policy --user-name ecr-user --policy-arn arn:aws:iam::$1:policy/ecr-full-access-policy
aws iam delete-policy --policy-arn arn:aws:iam::$1:policy/ecr-full-access-policy

aws iam create-policy --policy-name ecr-full-access-policy --policy-document file://scripts/ecr-policy.json
aws iam create-user --user-name ecr-user
aws iam attach-user-policy --user-name ecr-user --policy-arn arn:aws:iam::$1:policy/ecr-full-access-policy

aws iam create-access-key --user-name ecr-user >./scripts/aws-keys
