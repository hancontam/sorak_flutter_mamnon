import '../../modules/classes/models/school_class.dart';
import 'text_normalizer.dart';

const _gradeOrder = <String, int>{'nha tre': 0, 'mam': 1, 'choi': 2, 'la': 3};

int classGradeRank(String ageGroup) {
  return _gradeOrder[normalizeVietnamese(ageGroup).trim()] ?? 99;
}

List<SchoolClass> sortedClassesByGrade(Iterable<SchoolClass> classes) {
  final result = classes.toList();
  result.sort((a, b) {
    final byGrade = classGradeRank(
      a.ageGroup,
    ).compareTo(classGradeRank(b.ageGroup));
    if (byGrade != 0) return byGrade;

    final byName = normalizeVietnamese(
      a.className,
    ).compareTo(normalizeVietnamese(b.className));
    if (byName != 0) return byName;

    return normalizeVietnamese(a.room).compareTo(normalizeVietnamese(b.room));
  });
  return result;
}
