EXEFILE = app
OBJDIR = build
SRCDIR = src
SOURCES = $(wildcard $(SRCDIR)/*.c) $(wildcard $(SRCDIR)/*.s)
OBJECTS = $(patsubst $(SRCDIR)/%.c,$(OBJDIR)/%.o,$(filter %.c,$(SOURCES))) \
          $(patsubst $(SRCDIR)/%.s,$(OBJDIR)/%.o,$(filter %.s,$(SOURCES)))
CC = cc
NASM = nasm
CCFLAGS = -m64 -g
NASMFLAGS = -f elf64 -g -F dwarf -w+all

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	@mkdir -p $(OBJDIR)
	$(CC) $(CCFLAGS) -c -o $@ $<

$(OBJDIR)/%.o: $(SRCDIR)/%.s
	@mkdir -p $(OBJDIR)
	$(NASM) $(NASMFLAGS) -l $(OBJDIR)/$*.lst -o $@ $<

$(EXEFILE): $(OBJECTS)
	$(CC) $(CCFLAGS) -o $@ $^

clean:
	@rm -rf $(OBJDIR)/*.o $(OBJDIR)/*.lst $(EXEFILE)

.PHONY: clean
