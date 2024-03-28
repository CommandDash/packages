import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

String computeCodeHash(String fileContents) {
  // Normalize the file content by removing whitespace and newlines
  String normalizedContent = fileContents.replaceAll(RegExp(r'\s+'), '');
  var bytes = utf8.encode(normalizedContent); // data being hashed
  var digest = sha256.convert(bytes);
  return digest.toString();
}

double calculateCosineSimilarity(
    List<double> embedding1, List<double> embedding2) {
  // Check if the embeddings have the same length
  if (embedding1.length != embedding2.length) {
    throw ArgumentError('Embeddings must have the same length');
  }

  // Calculate the dot product of the two embeddings
  double dotProduct = 0;
  for (int i = 0; i < embedding1.length; i++) {
    dotProduct += embedding1[i] * embedding2[i];
  }

  // Calculate the magnitudes of the embeddings
  double magnitude1 =
      sqrt(embedding1.map((e) => e * e).reduce((a, b) => a + b));
  double magnitude2 =
      sqrt(embedding2.map((e) => e * e).reduce((a, b) => a + b));

  // Calculate the cosine similarity
  double cosineSimilarity = dotProduct / (magnitude1 * magnitude2);

  return cosineSimilarity;
}
