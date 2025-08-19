class OnboardingContent {
  String image;
  String title;
  String description;

  OnboardingContent({
    required this.image,
    required this.title,
    required this.description,
  });
}

final List<OnboardingContent> contents = [
  OnboardingContent(
    image: "assets/onboarding/onboarding_1.json",
    title: "Atur Jadwal",
    description: "Dengan aturin, kamu bisa mengatur jadwalmu agar kehidupanmu lebih tertata.",
  ),
  OnboardingContent(
    image: "assets/onboarding/onboarding_2.json",
    title: "Atur Tugas",
    description: "Dengan aturin, kamu bisa mencatat tugas-tugasmu agar kehidupanmu lebih tertata.",
  ),
  OnboardingContent(
    image: "assets/onboarding/onboarding_3.json",
    title: "Work Life Balance",
    description: "Mulai kehidupan Work Life Balancemu dengan Aturin!",
  ),
];
