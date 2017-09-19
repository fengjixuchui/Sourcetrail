#ifndef QT_CODE_FILE_H
#define QT_CODE_FILE_H

#include <memory>
#include <string>
#include <vector>

#include <QFrame>

#include "utility/file/FilePath.h"

#include "component/view/helper/CodeSnippetParams.h"
#include "qt/element/QtIconButton.h"

class QLabel;
class QPushButton;
class QtCodeArea;
class QtCodeFileTitleButton;
class QtCodeNavigator;
class QtCodeSnippet;
class QVBoxLayout;
class TimeStamp;

class QtCodeFile
	: public QFrame
{
	Q_OBJECT

public:
	QtCodeFile(const FilePath& filePath, QtCodeNavigator* navigator);
	virtual ~QtCodeFile();

	void setModificationTime(const TimeStamp modificationTime);

	const FilePath& getFilePath() const;
	std::string getFileName() const;

	QtCodeSnippet* addCodeSnippet(const CodeSnippetParams& params);
	QtCodeSnippet* insertCodeSnippet(const CodeSnippetParams& params);

	QtCodeSnippet* getSnippetForLocationId(Id locationId) const;
	QtCodeSnippet* getSnippetForLine(unsigned int line) const;
	QtCodeSnippet* getFileSnippet() const;

	std::pair<QtCodeSnippet*, Id> getFirstSnippetWithActiveLocationId(Id tokenId) const;

	bool isCollapsed() const;

	void requestContent();
	void updateContent();

	void setWholeFile(bool isWholeFile, int refCount);
	void setIsComplete(bool isComplete);

	void setMinimized();
	void setSnippets();
	void setMaximized();

	bool hasSnippets() const;
	void updateSnippets();
	void updateTitleBar();

	void findScreenMatches(const std::string& query, std::vector<std::pair<QtCodeArea*, Id>>* screenMatches);

public slots:
	void clickedMinimizeButton();
	void clickedSnippetButton();
	void clickedMaximizeButton();

	void enteredTitleBar(QPushButton* button);
	void leftTitleBar(QPushButton* button);

private slots:
	void clickedTitleBar();

private:
	void updateRefCount(int refCount);

	QtCodeNavigator* m_navigator;

	QPushButton* m_titleBar;
	QtCodeFileTitleButton* m_title;
	QLabel* m_referenceCount;

	QtIconStateButton* m_minimizeButton;
	QtIconStateButton* m_snippetButton;
	QtIconStateButton* m_maximizeButton;

	QVBoxLayout* m_snippetLayout;
	std::vector<std::shared_ptr<QtCodeSnippet>> m_snippets;
	std::shared_ptr<QtCodeSnippet> m_fileSnippet;

	const FilePath m_filePath;

	bool m_isWholeFile;
	bool m_isCollapsed;

	mutable bool m_contentRequested;
};

#endif // QT_CODE_FILE_H
