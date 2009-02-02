tName(dme26,'David Eyers'). 
tName(awm22,'Andrew Moore'). 
tCollege(dme26, 'King''s'). 
tCollege(awm22, 'Corpus Christi'). 
tGrade(dme26,'IB',1). 
tGrade(dme26,'II',1). 
tGrade(dme26,'IA',2.1). 
tGrade(awm22,'IB',1). 
tGrade(awm22,'II',1). 
tGrade(awm22,'IA',2.1). 

noWorseExists(Person, Grade) :- tGrade(Person, _, Other), Other > Grade, !, fail. 
noWorseExists(_, _).

worst(Person, Grade) :- tGrade(Person, _, Grade), noWorseExists(Person, Grade).

newSolution(Sol, []).
newSolution(Sol, [Exist|ExistT]) :- Sol \== Exist, newSolution(Sol, ExistT).

gradeTuple(Person, (Year, Grade)) :- tGrade(Person, Year, Grade).

noMoreExist(Person, AllGrades) :- gradeTuple(Person, Sol), newSolution(Sol, AllGrades), !, fail.
noMoreExist(_, _).

allGrades(Person, FoundGrades, [Grade|AllGrades]) :- gradeTuple(Person, Grade), newSolution(Grade, FoundGrades), allGrades(Person, [Grade|FoundGrades], AllGrades).
allGrades(Person, Grades, []) :- noMoreExist(Person, Grades).
allGrades(Person, Grades) :- allGrades(Person, [], Grades), !.
