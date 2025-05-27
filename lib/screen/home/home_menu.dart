class Screen {
  final String title;
  final String description;
  final String image;
  final String color;
  final String backgroundColor;

  Screen({
    required this.title,
    required this.description,
    required this.image,
    required this.color,
    required this.backgroundColor,
  });
}

final List<Screen> listOfMenu = [
  Screen(
      title: "Material Maintenance",
      description: "Material Information Management",
      image: "images/icon_maintenance.png	",
      color: "0Xff008a8d",
      backgroundColor: "0xffffffff"),
];
