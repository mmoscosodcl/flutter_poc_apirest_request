/// Parsed domain data from GitHub REST API (HTTP 200).
class GitHubUser {
  final String login;
  final String? name;
  final String avatarUrl;
  final String? bio;
  final String? company;
  final String? location;
  final int publicRepos;
  final int followers;
  final int following;
  final String htmlUrl;

  const GitHubUser({
    required this.login,
    this.name,
    required this.avatarUrl,
    this.bio,
    this.company,
    this.location,
    required this.publicRepos,
    required this.followers,
    required this.following,
    required this.htmlUrl,
  });

  factory GitHubUser.fromJson(Map<String, dynamic> json) {
    return GitHubUser(
      login: json['login'] as String? ?? 'anonymous',
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String? ?? '',
      bio: json['bio'] as String?,
      company: json['company'] as String?,
      location: json['location'] as String?,
      publicRepos: (json['public_repos'] as num?)?.toInt() ?? 0,
      followers: (json['followers'] as num?)?.toInt() ?? 0,
      following: (json['following'] as num?)?.toInt() ?? 0,
      htmlUrl: json['html_url'] as String? ?? '',
    );
  }
}
