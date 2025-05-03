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
    image: "assets/images/onboarding_images/schedule.gif",
    title: "Atur Jadwal",
    description: "Dengan aturin, kamu bisa mengatur jadwalmu agar kehidupanmu lebih tertata.",
  ),
  OnboardingContent(
    image: "assets/images/onboarding_images/task.gif",
    title: "Atur Tugas",
    description: "Dengan aturin, kamu bisa mencatat tugas-tugasmu agar kehidupanmu lebih tertata.",
  ),
  OnboardingContent(
    image: "assets/images/onboarding_images/work_life_balance.gif",
    title: "Work Life Balance",
    description: "Mulai kehidupan Work Life Balancemu dengan Aturin!",
  ),
];
