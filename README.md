##Text Analysis of the Indian Claims Commission Decisions
==============

The Indian Claims Commission was a legal body that adjudicated hundreds of claims that Indian Tribes had against the United States for past wrongs. It produced 43 volumes of decisions over more than 30 years of work. Though the ICC tried cases to legal standards, it was of its time and reflected changing attitudes towards Native Americans. This work attempts to examine its place in Federal-Indian policy and analyze how the Commission used historical knowledge to arrive at legal decisions. It is also a case study in using text mining to explore a large corpus (n=100%) of legal documents computationally.

This analysis collected the the Decisions from [Oklahoma State University:](http://digital.library.okstate.edu/icc/index/iccindex.htm)
Performed OCR of the PDFs using tesseract and Lincoln Mullen's make recipe from [Civil-Procedure-Codes](https://github.com/lmullen/civil-procedure-codes)

Use the Makefile to perform each of the tasks- download, collect PDFs, OCR, collect tables/plaintiff tribes. I'd highly recommend running the OCR in parallel using `make ocr -j2`

The rest of the work is various R scripts that process and analyze the textural data. Use load.r and topic.r to perform the work. Table.r is a script to collect the plaintiff tribe names for the stoplist. Best practice is to use the curated stoplist on github as manual changes have been made to it.

It was created as a final class project for CLIO3: Hist 698 at George Mason University.

Visualizations at [Petercarrjones.com](http://www.petercarrjones.com/projects/mining-the-icc/)
