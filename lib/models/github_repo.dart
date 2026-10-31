// Modelo que representa un repositorio de GitHub.
class GitHubRepo {
  final int id;
  final String? name;
  final String description;
  final int stargazersCount;
  final String htmlUrl;

  const GitHubRepo({
    required this.id,
    required this.name,
    required this.description,
    required this.stargazersCount,
    required this.htmlUrl,
  });

  // Convierte la respuesta JSON de la API en un objeto GitHubRepo.
  factory GitHubRepo.fromJson(Map<String, dynamic> json) {
    return GitHubRepo(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String?,
      description: json['description'] as String? ?? '',
      stargazersCount: json['stargazers_count'] as int? ?? 0,
      htmlUrl: json['html_url'] as String? ?? '',
    );
  }
}
