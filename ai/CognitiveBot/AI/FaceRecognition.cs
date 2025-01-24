using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection.Metadata;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Azure.CognitiveServices.Vision.Face;
using Microsoft.Azure.CognitiveServices.Vision.Face.Models;
using Microsoft.Extensions.Logging;

namespace EchoBot.AI
{
    public record Faces(IList<string> Names = null, int TotalFaces = 0);
    public record QualityFaces(IList<DetectedFace> Faces, int TotalFaces);

    /// <summary>
    /// Provides methods for face recognition using Azure Face API.
    /// </summary>
    public class FaceRecognition(ILogger<FaceRecognition> logger, IFaceClient client)
    {
        /// <summary>
        /// The default person group ID used for face identification.
        /// </summary>
        public const string DefaultPersonGroupId = "f250b46c-4f01-41be-8300-82b596311b36";

        /// <summary>
        /// Detect faces from image url for recognition purposes. This is a helper method for other functions in this quickstart.
        /// Parameter `returnFaceId` of `DetectWithUrlAsync` must be set to `true` (by default) for recognition purposes.
        /// Parameter `FaceAttributes` is set to include the QualityForRecognition attribute. 
        /// Recognition model must be set to recognition_03 or recognition_04 as a result.
        /// Result faces with insufficient quality for recognition are filtered out. 
        /// The field `faceId` in returned `DetectedFace`s will be used in Face - Face - Verify and Face - Identify.
        /// It will expire 24 hours after the detection call.
        /// </summary>
        /// <param name="stream">The image stream to detect faces from.</param>
        /// <param name="recognition_model">The recognition model to use (e.g., recognition_03 or recognition_04).</param>
        /// <returns>A list of detected faces with sufficient quality for recognition.</returns>
        private async Task<QualityFaces> DetectFaceRecognizeAsync(Stream stream, string recognition_model, CancellationToken cancellationToken = default)
        {
            // Detect faces from image URL. Since only recognizing, use the recognition model 1.
            // We use detection model 3 because we are not retrieving attributes.
            IList<DetectedFace> detectedFaces = await client.Face.DetectWithStreamAsync(stream, recognitionModel: recognition_model, detectionModel: DetectionModel.Detection03, returnFaceAttributes: [FaceAttributeType.QualityForRecognition], cancellationToken: cancellationToken);
            List<DetectedFace> sufficientQualityFaces = [];
            foreach (DetectedFace detectedFace in detectedFaces)
            {
                var faceQualityForRecognition = detectedFace.FaceAttributes.QualityForRecognition;
                if (faceQualityForRecognition.HasValue && (faceQualityForRecognition.Value >= QualityForRecognition.Medium))
                {
                    sufficientQualityFaces.Add(detectedFace);
                }
            }
            logger.LogInformation("{count} face(s) with {countQuality} having sufficient quality for recognition detected from image.", detectedFaces.Count, sufficientQualityFaces.Count);

            return new QualityFaces(sufficientQualityFaces, detectedFaces.Count);
        }

        /// <summary>
        /// To identify faces, you need to create and define a person group.
        /// The Identify operation takes one or several face IDs from DetectedFace or PersistedFace and a PersonGroup and returns
        /// a list of Person objects that each face might belong to.Returned Person objects are wrapped as Candidate objects,
        /// which have a prediction confidence value.
        /// </summary>
        /// <param name="stream">The image stream to detect and identify faces from.</param>
        /// <param name="recognitionModel">The recognition model to use (default is recognition_04).</param>
        /// <returns>A list of names of identified persons.</returns>
        public async Task<Faces> IdentifyInPersonGroupAsync(Stream stream, string recognitionModel = RecognitionModel.Recognition04, string personGroupId = DefaultPersonGroupId, CancellationToken cancellationToken = default)
        {
            logger.LogInformation("Detecting faces for recognition");
            var detectedFaces = await DetectFaceRecognizeAsync(stream, recognitionModel);
            List<Guid> sourceFaceIds = [.. detectedFaces.Faces.Where(face => face.FaceId != null).OrderBy(face => face.FaceRectangle.Left).Select(face => face.FaceId!.Value)];

            if (sourceFaceIds.Count == 0)
            {
                logger.LogInformation("No faces detected in the image.");
                return new Faces(TotalFaces: detectedFaces.TotalFaces);
            }

            // Identify the faces in a person group. 
            var identifyResults = await client.Face.IdentifyAsync(sourceFaceIds, personGroupId, cancellationToken: cancellationToken);
            List<string> personNames = [];
            foreach (var identifyResult in identifyResults)
            {
                if (identifyResult.Candidates.Count == 0)
                {
                    logger.LogInformation("No person is identified for the face in: {FaceId}, ", identifyResult.FaceId);
                    continue;
                }
                Person person = await client.PersonGroupPerson.GetAsync(personGroupId, identifyResult.Candidates[0].PersonId, cancellationToken);
                logger.LogInformation("Person '{name}' is identified for the face in: {FaceId}, confidence: {confidence}.", person.Name, identifyResult.FaceId, identifyResult.Candidates[0].Confidence);

                VerifyResult verifyResult = await client.Face.VerifyFaceToPersonAsync(identifyResult.FaceId, person.PersonId, personGroupId, cancellationToken: cancellationToken);
                logger.LogInformation("Verification result: is a match? {isIdentical}. confidence: {confidence}", verifyResult.IsIdentical, verifyResult.Confidence);
                if (verifyResult.IsIdentical)
                {
                    personNames.Add(person.Name);
                }
            }
            return new Faces(personNames, detectedFaces.TotalFaces);
        }
    }
}