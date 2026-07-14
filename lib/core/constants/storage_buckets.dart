/// Buckets do Supabase Storage (09_SUPABASE_SQL.md).
///
/// Todos privados; o acesso ocorre via URLs assinadas.
abstract final class StorageBuckets {
  const StorageBuckets._();

  static const String avatars = 'avatars';
  static const String progressPhotos = 'progress_photos';
  static const String mealPhotos = 'meal_photos';
  static const String exerciseImages = 'exercise_images';
  static const String exerciseGifs = 'exercise_gifs';
  static const String exerciseVideos = 'exercise_videos';

  static const List<String> all = [
    avatars,
    progressPhotos,
    mealPhotos,
    exerciseImages,
    exerciseGifs,
    exerciseVideos,
  ];
}
