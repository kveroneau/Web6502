extern void InitWebDisk(unsigned char cardid);
extern unsigned char WD_LoadFile(char* fname, void* dest);
extern void WD_ExecPRG(char* fname);
extern unsigned char WD_LoadTextFile(char* fname, char* target);
extern unsigned char WD_LoadMarkdown(char* fname, char* target);
