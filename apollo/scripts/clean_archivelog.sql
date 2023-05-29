run 
{
	crosscheck archivelog all;
	delete noprompt archivelog until time 'sysdate';
}
