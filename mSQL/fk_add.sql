ALTER TABLE ftbint3.l10n_text_resource ADD CONSTRAINT fk_fk_l10ntextresource_bundle FOREIGN KEY (bundle_id) REFERENCES ftbint3.l10n_resource_bundle (id); 
ALTER TABLE ftbint3.l10n_text_resource ADD CONSTRAINT fk_fk_l10ntextresource_company FOREIGN KEY (company_id) REFERENCES ftbint3.company (id);           
ALTER TABLE ftbint3.l10n_text_resource ADD CONSTRAINT fk_fk_l10ntextresource_locale FOREIGN KEY (locale_id) REFERENCES ftbint3.l10n_locale (id);       
