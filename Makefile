

# rule for making release
RNAME = mtex-5.0.2
RDIR = ../releases
release:
	rm -rf $(RDIR)/$(RNAME)*
	cp -R . $(RDIR)/$(RNAME)
	rm -rf $(RDIR)/$(RNAME)/help/tmp
	chmod -R a+rX $(RDIR)/$(RNAME)
	rm -rf $(RDIR)/$(RNAME)/.git
	rm -rf $(RDIR)/$(RNAME)/.git*
	rm -rf $(RDIR)/$(RNAME)/doc/html/helpsearch*
	find $(RDIR)/$(RNAME) -name '*~' -or -name '*.log' -or -name '*.o' -or -name '*.orig' -or -name '.directory' -or -name '*.mat' | xargs /bin/rm -rf
	rm -f $(RDIR)/$(RNAME)/c/nsoft/test_nfsoft_adjoint
	rm -rf $(RDIR)/$(RNAME)/help/html
	rm -rf $(RDIR)/$(RNAME).zip

	cd $(RDIR); zip -rq  $(RNAME).zip $(RNAME)
