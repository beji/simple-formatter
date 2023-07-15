
%.json:
	@./wrap-jq.sh $@

%.yaml:
	@./wrap-yq.sh $@

%.yml:
	@./wrap-yq.sh $@
