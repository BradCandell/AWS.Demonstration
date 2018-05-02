using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Amazon.Lambda.Core;
using Amazon.S3;
using Amazon.S3.Model;

// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.Json.JsonSerializer))]
namespace AWS.Demonstration.Lambda {

    /// <summary>
    /// Amazon Lambda - Create Date-Stamped S3 File
    /// </summary>
    public class Function {


        /// <summary>
        /// Default Constructor
        /// </summary>
        public Function() {

        }




        /// <summary>
        /// Amazon Lambda Function - Create 
        /// </summary>
        /// <param name="context">Lambda Context</param>
        /// <returns>S3 Object Key</returns>
        public async Task<string> CreateDateStampedObject(ILambdaContext context) {

            // Setup the default Bucket Name and Date Format
            string bucketName = SetVariable("LB_BUCKET", "hfinch");
            string dateFormatString = SetVariable("LB_DATEFORMAT", "MM/dd/yyyy hh:mm:ss");
            
            // Create the Contents and Key of the object to be created
            string contents = DateTime.UtcNow.ToString(dateFormatString);
            string key = Guid.NewGuid().ToString();


            // PUT the S3 Object in the proper location
            bool results = await PutS3Object(bucketName, key, contents);
            

            // Handle the success of the PUT operation.
            if (results) {
                return key;
            }
            else {
                InvalidOperationException ex = new InvalidOperationException("Unable to create an S3 Object within the specified location [" + bucketName + "]");
                ex.Data.Add("key", key);
                ex.Data.Add("bucket", bucketName);
                throw ex;
            }


        }

        /// <summary>
        /// Put (or create) an S3 Object using the specified parameters
        /// </summary>
        /// <param name="bucketName">Bucket Name</param>
        /// <param name="objectKey">S3 Object Key</param>
        /// <param name="objectContents">Contents of the S3 Object</param>
        /// <returns>True, if successful</returns>
        public async Task<bool> PutS3Object(string bucketName, string objectKey, string objectContents) {

            try {
                using(IAmazonS3 s3Client = new AmazonS3Client(Amazon.RegionEndpoint.USEast1)) {

                    // Create the PUT Request
                    var putRequest = new PutObjectRequest() {
                        BucketName = bucketName,
                        Key = objectKey,
                        ContentType = "text/plain",
                        ContentBody = objectContents
                    };

                    var putResponse = await s3Client.PutObjectAsync(putRequest);
                    return true;

                }
            }
            catch (Exception ex) {
                Console.WriteLine("An error occurred during the 'PUT' operation -> " + ex.Message);
                return false;
            }
        }

        /// <summary>
        /// Set a Variable value based on the either the existence of an environment variable value, or the specified default value.
        /// </summary>
        /// <param name="environmentVariable">The name of the Environment Variable</param>
        /// <param name="defaultValue">The default value, if the Environment Variable is non-existent or empty</param>
        /// <returns>Value of the specified Environment Variable</returns>
        private string SetVariable(string environmentVariable, string defaultValue) {
            
            if (string.IsNullOrWhiteSpace(environmentVariable) || string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable(environmentVariable))) {
                return defaultValue;
            }

            return Environment.GetEnvironmentVariable(environmentVariable);

        }


    }
}
