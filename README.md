Sum up the space you are, or I am, using on Amazon AWS S3

Parameters

 Parameter   Description
 --buckets   Optional regular expression to choose the buckets to be summed
 --profile   Optional aws cli --profile keyword to choose the account to sum

Examples

 perl spaceUsedOnS3.pl
 perl spaceUsedOnS3.pl --profile abc --buckets "\Ap"

Notes

You will need IAM permissions for the credentials identified by the --profile keyword to list buckets and objects associated with the credentials.

The --buckets selection regular expression is applied in a case insensitive manner.

